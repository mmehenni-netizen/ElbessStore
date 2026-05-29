const express = require('express')
const path = require('path'); 
const mongoose = require('mongoose')
const dns = require('dns');
const morgan = require('morgan')
const crypto = require('crypto')
const multer = require('multer'); 
const bcrypt = require('bcrypt')
const fs = require('fs');
require('dotenv').config();
const cloudinary = require('cloudinary').v2;
const Order = require('./model/Order_model.js')
const Store  = require('./model/Store_model.js')
const Product  = require('./model/Product_model.js')
const { sendVerificationEmail } = require('./utils/sendEmail.js'); 
const { getAlreadyVerifiedPage, getSuccessPage, getErrorPage } = require('./templates/email-verification');
const { getProductById, updateProductById, deleteProductById } = require('./repo/inventoryRepo.js');

const isCloudinaryConfigured = Boolean(
    process.env.CLOUDINARY_CLOUD_NAME &&
    process.env.CLOUDINARY_API_KEY &&
    process.env.CLOUDINARY_API_SECRET
);

if (isCloudinaryConfigured) {
    cloudinary.config({
        cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
        api_key: process.env.CLOUDINARY_API_KEY,
        api_secret: process.env.CLOUDINARY_API_SECRET,
        secure: true,
    });
} else {
    console.warn('Cloudinary is not configured. Image uploads require CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET.');
}

const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}


const upload = multer({ storage: multer.memoryStorage() });

function uploadBufferToCloudinary(file, folder) {
    return new Promise((resolve, reject) => {
        if (!file || !file.buffer) {
            resolve(null);
            return;
        }

        if (!isCloudinaryConfigured) {
            reject(new Error('Cloudinary is not configured on the server'));
            return;
        }

        try {
            const stream = cloudinary.uploader.upload_stream(
                {
                    folder,
                    resource_type: 'image',
                },
                (error, result) => {
                    if (error) {
                        reject(error);
                        return;
                    }

                    resolve(result);
                }
            );

            stream.end(file.buffer);
        } catch (error) {
            reject(error);
        }
    });
}

function getCloudinaryPublicId(imageUrl) {
    if (typeof imageUrl !== 'string' || !imageUrl.includes('/upload/')) {
        return null;
    }

    const uploadSegment = imageUrl.split('/upload/')[1];
    if (!uploadSegment) {
        return null;
    }

    const pathWithoutQuery = uploadSegment.split('?')[0];
    const withoutVersion = pathWithoutQuery.replace(/^v\d+\//, '');
    const withoutExtension = withoutVersion.replace(/\.[^.\/]+$/, '');

    return withoutExtension || null;
}

async function deleteCloudinaryImage(imageUrl) {
    const publicId = getCloudinaryPublicId(imageUrl);
    if (!publicId) {
        return false;
    }

    await cloudinary.uploader.destroy(publicId, { resource_type: 'image' });
    return true;
}

// Archive delivered orders older than `retentionDays` (in days)
async function archiveDeliveredOrders(retentionDays = 90) {
    try {
        const cutoff = new Date(Date.now() - retentionDays * 24 * 60 * 60 * 1000);
        const result = await Order.updateMany(
            { delivered: true, deliveryDate: { $lte: cutoff }, archived: { $ne: true } },
            { $set: { archived: true, deletedAt: new Date() } }
        );
        console.log(`archiveDeliveredOrders: archived ${result.modifiedCount} orders older than ${retentionDays} days`);
        return result.modifiedCount;
    } catch (err) {
        console.error('archiveDeliveredOrders error:', err);
        throw err;
    }
}

// Permanently purge archived orders older than `retentionDays` (in days)
async function purgeArchivedOrders(retentionDays = 365) {
    try {
        const cutoff = new Date(Date.now() - retentionDays * 24 * 60 * 60 * 1000);
        const result = await Order.deleteMany({ archived: true, deletedAt: { $lte: cutoff } });
        console.log(`purgeArchivedOrders: purged ${result.deletedCount} archived orders older than ${retentionDays} days`);
        return result.deletedCount;
    } catch (err) {
        console.error('purgeArchivedOrders error:', err);
        throw err;
    }
}



const app = express()


const allowedOrigins = (process.env.CORS_ORIGIN || process.env.CLIENT_URL || '*')

app.use((req, res, next) => {
    const origin = req.headers.origin;
    const isLocalOrigin = typeof origin === 'string' && /^(https?:\/\/)?(localhost|127\.0\.0\.1)(:\d+)?$/i.test(origin);

    if (allowedOrigins === '*') {
        res.setHeader('Access-Control-Allow-Origin', '*');
    } else if (
        origin && (
            allowedOrigins.split(',').map((item) => item.trim()).includes(origin) ||
            isLocalOrigin
        )
    ) {
        res.setHeader('Access-Control-Allow-Origin', origin);
        res.setHeader('Vary', 'Origin');
    }

    res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
        return res.sendStatus(204);
    }

    next();
});

app.use(express.json())
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));
app.use('/uploads', express.static(uploadsDir));

//url link
const Urldb =process.env.MONGODB_URI;
const fallbackUrldb = process.env.MONGODB_URI_FALLBACK;

if (process.env.DNS_SERVERS) {
    const dnsServers = process.env.DNS_SERVERS
        .split(',')
        .map((server) => server.trim())
        .filter(Boolean);

    if (dnsServers.length > 0) {
        dns.setServers(dnsServers);
        console.log('Using custom DNS servers:', dnsServers.join(', '));
    }
}

const mongoConnectionOptions = {
    serverSelectionTimeoutMS: 30000,
    socketTimeoutMS: 30000,
};

function isSrvDnsTimeout(error) {
    return (
        error &&
        (error.code === 'ETIMEOUT' || error.code === 'ENOTFOUND') &&
        error.syscall === 'queryTxt'
    );
}

async function connectToMongoWithFallback() {
    if (!Urldb) {
        throw new Error('MONGODB_URI is missing in environment variables');
    }

    try {
        await mongoose.connect(Urldb, mongoConnectionOptions);
        console.log('Connected to MongoDB');
        return;
    } catch (error) {
        if (!isSrvDnsTimeout(error)) {
            throw error;
        }

        console.error('MongoDB SRV DNS lookup failed:', error.message);

        if (!fallbackUrldb) {
            console.error('Set MONGODB_URI_FALLBACK to a non-SRV mongodb:// URI from Atlas (with all hosts) to bypass SRV DNS lookups.');
            throw error;
        }

        console.log('Retrying MongoDB connection using MONGODB_URI_FALLBACK...');
        await mongoose.connect(fallbackUrldb, mongoConnectionOptions);
        console.log('Connected to MongoDB using fallback URI');
    }
}

//connect to database
connectToMongoWithFallback()
    .then(() => {
        const port = Number(process.env.PORT || 3000);
        const server = app.listen(port, () => {
            console.log(`Server is running on port ${port}`);
        });

        // Schedule daily archival and purge tasks
        const archiveRetentionDays = Number(process.env.ARCHIVE_RETENTION_DAYS ?? 90);
        const purgeRetentionDays = Number(process.env.PURGE_RETENTION_DAYS ?? 365);

        // Run once at startup (non-blocking)
        archiveDeliveredOrders(archiveRetentionDays).catch((err) => console.error(err));
        purgeArchivedOrders(purgeRetentionDays).catch((err) => console.error(err));

        // Schedule to run daily
        const dayMs = 24 * 60 * 60 * 1000;
        setInterval(() => {
            archiveDeliveredOrders(archiveRetentionDays).catch((err) => console.error(err));
            purgeArchivedOrders(purgeRetentionDays).catch((err) => console.error(err));
        }, dayMs);

        return server;
    })
    .catch((err) => {
        console.error('MongoDB connection error:', err);
    });


async function getStoreName({ id, address }) {
    if (id) {
        const storeById = await Store.findById(id).lean();
        return storeById?.name ?? null;
    }

    if (address) {
        const normalizedAddress = address.trim().toLowerCase();
        if (!normalizedAddress) {
            return null;
        }

        const escapedAddress = normalizedAddress.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        const storeByAddress = await Store.findOne({
            address: { $regex: `^\\s*${escapedAddress}\\s*$`, $options: 'i' },
        }).lean();
        return storeByAddress?.name ?? null;
    }

    return null;
}


app.post('/GetStoreName', async (req, res) => {
    try {
        const id = req.body.Id ?? req.body.id;
        const address = req.body.Address ?? req.body.address;

        const name = await getStoreName({ id, address });

        if (!name) {
            return res.json({
                success: false,
                message: 'Store not found',
            });
        }

        return res.json({
            success: true,
            name,
        });
    } catch (error) {
        console.error('GetStoreName error:', error);
        return res.status(500).json({
            success: false,
            message: 'Server error while getting store name',
        });
    }
});




app.post("/SignIn", async (req, res) => {
    try {
        const rawAddress = req.body.Address ?? req.body.address;
        const rawPassword = req.body.Password ?? req.body.password;

        const address = typeof rawAddress === 'string' ? rawAddress.trim().toLowerCase() : '';
        const password = typeof rawPassword === 'string' ? rawPassword : '';

        if (!address || !password) {
            return res.status(400).json({
                find: false,
                message: "Address and Password are required",
            });
        }

        // Try direct match first (case-insensitive)
        let result = await Store.findOne({
            address: address
        }).lean();

        // If not found, try with regex pattern
        if (!result) {
            const escapedAddress = address.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            result = await Store.findOne({
                $or: [
                    { address: { $regex: `^${escapedAddress}$`, $options: 'i' } },
                    { Address: { $regex: `^${escapedAddress}$`, $options: 'i' } },
                ],
            }).lean();
        }

        if (!result) {
            console.log(`[SignIn] Store not found for address: ${address}`);
            return res.json({
                find: false,
                message: "Store not found",
            });
        }

        const storedPassword = typeof result.password === 'string'
            ? result.password
            : typeof result.Password === 'string'
                ? result.Password
                : '';
        const inputPasswords = [password, password.trim()].filter((value, index, arr) => value && arr.indexOf(value) === index);

        const isHashedPassword = storedPassword.startsWith('$2');
        const passwordMatches = isHashedPassword
            ? (await Promise.all(inputPasswords.map((candidate) => bcrypt.compare(candidate, storedPassword)))).some(Boolean)
            : inputPasswords.some((candidate) => storedPassword === candidate || storedPassword.trim() === candidate.trim());

        if (!passwordMatches) {
            console.log(`[SignIn] Password mismatch for address: ${address}`);
            return res.json({
                find: false,
                message: "Invalid password",
            });
        }

        res.json({
            find: true,
            result,
        });
    } catch (error) {
        console.error('SignIn error:', error);
        res.status(500).json({
            find: false,
            message: 'Server error during sign in',
        });
    }
})

app.post("/SignUp", upload.single('Logo'), async (req, res) => {

    try {
        const rawAddress = req.body.Address ?? req.body.address;
        const rawPassword = req.body.Password ?? req.body.password;
        const address = typeof rawAddress === 'string' ? rawAddress.trim().toLowerCase() : '';
        const password = typeof rawPassword === 'string' ? rawPassword.trim() : '';

        if (!address || !password) {
            return res.status(400).json({
                creation: false,
                message: "Address and Password are required",
            });
        }

        const result = await Store.findOne({
            address: { $regex: `^\\s*${address.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\s*$`, $options: 'i' },
        });

        if (result) {
            return res.json({
                creation: false,
                message: "Store already exists",
            });
        }

        const verificationToken = crypto.randomBytes(32).toString('hex');
        const hashedPassword = await bcrypt.hash(password, 10);
        const uploadedLogo = await uploadBufferToCloudinary(req.file, 'elbess-store/logos');
        const logoPath = uploadedLogo?.secure_url || process.env.DEFAULT_LOGO_URL || '';

        const newStore = new Store({
            address: address,
            password: hashedPassword,
            emailVerificationToken: verificationToken,
            name: req.body.Name ?? req.body.name,
            location: req.body.Location ?? req.body.location,
            description: req.body.Description ?? req.body.description,
            logo: logoPath,
        });

        await newStore.save();
        await sendVerificationEmail(address, verificationToken);

        return res.json({
            creation: true,
            message: "Store created successfully",
            result: newStore.toObject(),
        });
    } catch (error) {
        console.error('SignUp error:', error);
        return res.status(500).json({
            creation: false,
            message: error?.message || 'Server error during sign up',
        });
    }
})


app.get("/verify-email", async (req, res) => {

    try {
        const { token } = req.query;

        if (!token) {
            return res.send(getErrorPage("Verification token is required"));
        }

        const store = await Store.findOne({ emailVerificationToken: token }).lean();

        if (!store) {
            return res.send(getErrorPage("Invalid or expired verification token"));
        }

        if (store.isEmailVerified) {
            return res.send(getAlreadyVerifiedPage(store.address));
        }

        await Store.updateOne(
            { _id: store._id },
            { $set: { isEmailVerified: true } }
        );

        res.send(getSuccessPage(store.address));

    } catch (error) {
        res.send(getErrorPage("Server error. Please try again later"));
    }
});

app.post("/CheckEmailVerification", async (req, res) => {
    try {
        const rawEmail = req.body.email ?? req.body.Email;
        const email = typeof rawEmail === 'string' ? rawEmail.trim().toLowerCase() : '';

        if (!email) {
            return res.status(400).json({
                isVerified: false,
                message: "Email is required",
            });
        }

        console.log(`[CheckEmailVerification] Looking for store with email: ${email}`);

        const store = await Store.findOne({
            address: email,
        }).lean();

        if (!store) {
            console.log(`[CheckEmailVerification] Store not found for email: ${email}`);
            return res.json({
                isVerified: false,
                message: "Store not found",
            });
        }

        console.log(`[CheckEmailVerification] Found store, isEmailVerified: ${store.isEmailVerified}`);

        const isVerified = store.isEmailVerified === true;

        return res.json({
            isVerified: isVerified,
        });
    } catch (error) {
        console.error('CheckEmailVerification error:', error);
        return res.status(500).json({
            isVerified: false,
            message: 'Server error',
        });
    }
});

app.post("/AddProduct", upload.single('Image'), async (req, res) => {

    try {
        const name = (req.body.Name ?? req.body.name ?? '').trim();
        const description = (req.body.Description ?? req.body.description ?? name).trim();
        const storeId = req.body.Store ?? req.body.store;
        const category = req.body.Category ?? req.body.category;
        const gender = req.body.Gender ?? req.body.gender;
        const price = Number(req.body.Price ?? req.body.price ?? 0);
        const rating = Number(req.body.Rating ?? req.body.rating ?? 0);
        const totalQuantity = Number(req.body.TotalQuantity ?? req.body.totalQuantity ?? 0);

        if (!name || !description || !storeId || !category || !gender || !Number.isFinite(price) || !Number.isFinite(totalQuantity)) {
            return res.status(400).json({
                creation: false,
                message: "Missing or invalid product fields",
            });
        }

        const uploadedImage = await uploadBufferToCloudinary(req.file, 'elbess-store/products');
        const imagePath = uploadedImage?.secure_url || "";
        let sizeQuantities = req.body.SizeQuantities ?? req.body.sizeQuantities ?? '[]';
        sizeQuantities = typeof sizeQuantities === 'string' ? JSON.parse(sizeQuantities) : sizeQuantities;

        const normalizedSizeQuantities = Array.isArray(sizeQuantities)
            ? sizeQuantities
                  .map((item) => ({
                      size: (item?.size ?? item?.Size ?? '').toString().trim(),
                      quantity: Number(item?.quantity ?? item?.Quantity ?? 0),
                  }))
                  .filter((item) => item.size && Number.isFinite(item.quantity))
            : [];

        if (normalizedSizeQuantities.length === 0) {
            return res.status(400).json({
                creation: false,
                message: "At least one valid size quantity is required",
            });
        }

        const newProduct = new Product({
            name,
            description,
            price,
            rating: Number.isFinite(rating) ? rating : 0,
            sizeQuantities: normalizedSizeQuantities,
            store: storeId,
            category,
            imageUrl: imagePath ? [imagePath] : [],
            totalQuantity,
            gender,
        });

        const savedProduct = await newProduct.save();
        await Store.findByIdAndUpdate(
            storeId,
            { $push: { products: savedProduct._id } }
        );

        return res.json({
            creation: true,
            result: savedProduct,
            message: "Product created successfully and added to store"
        });
    } catch (err) {
        console.log(err);
        return res.status(500).json({
            creation: false,
            message: "Error creating product",
            error: err.message
        });
    }
});

app.post('/GetProduct', async (req, res) => {
    try {
        const productId = req.body.id ?? req.body.Id ?? req.body.productId ?? req.body.ProductId;
        if (!productId) {
            return res.status(400).json({
                success: false,
                message: 'Product id is required',
            });
        }

        const product = await getProductById(productId);
        if (!product) {
            return res.json({
                success: false,
                message: 'Product not found',
            });
        }

        return res.json({
            success: true,
            product,
        });
    } catch (error) {
        console.error('GetProduct error:', error);
        return res.status(500).json({
            success: false,
            message: 'Error fetching product',
        });
    }
});

app.post('/EditProduct', upload.single('Image'), async (req, res) => {
    try {
        const productId = req.body.id ?? req.body.Id ?? req.body.productId ?? req.body.ProductId;
        if (!productId) {
            return res.status(400).json({
                success: false,
                message: 'Product id is required',
            });
        }

        const updatedProduct = await updateProductById(productId, req.body, req.file);
        if (!updatedProduct) {
            return res.json({
                success: false,
                message: 'Product not found',
            });
        }

        return res.json({
            success: true,
            message: 'Product updated successfully',
            product: updatedProduct,
        });
    } catch (error) {
        console.error('EditProduct error:', error);
        return res.status(500).json({
            success: false,
            message: error.message || 'Error updating product',
        });
    }
});


app.delete("/DeleteProduct", async (req, res) => {
    try {
        const productId = req.body.id ?? req.body.Id ?? req.body.productId ?? req.body.ProductId;
        const deletion = await deleteProductById(productId, uploadsDir);

        if (!deletion.deleted) {
            return res.json({
                deletion: false,
                message: deletion.message || 'Product not found'
            });
        }

        res.json({
            deletion: true,
            message: "Product deleted successfully from Product collection and Store array",
        });
        
    } catch (err) {
        console.log(err);
        res.status(500).json({
            deletion: false,
            message: "Error deleting product",
            error: err.message
        });
    }
});

app.post("/GetStoreProducts", async (req, res) => {
    try {
        const storeId = req.body.storeId ?? req.body.StoreId ?? req.body.store ?? req.body.Store ?? req.body.id ?? req.body.Id;
        if (!storeId) {
            return res.status(400).json({
                success: false,
                message: "Store id is required",
            });
        }

        const products = await Product.find({ store: storeId });

        res.json({
            success: true,
            count: products.length,
            products,
        });

    } catch (error) {
        console.error('Error fetching store products:', error);
        res.status(500).json({
            success: false,
            message: "Error fetching products",
            error: error.message
        });
    }
});

app.post("/AddOrder", async (req, res) => {
    try {
        const {
            store,
            user,
            product,
            quantity,
            size,
            Size,
            name,
            Name,
            location,
            Location,
            numero,
            Numero,
            office,
            domicile,
            products,
        } = req.body;

        const firstProduct = Array.isArray(products) && products.length > 0 ? products[0] : null;
        const productId = product ?? firstProduct?.product;
        const normalizedQuantity = Number(quantity ?? firstProduct?.quantity ?? 1);
        const normalizedSize = (size ?? Size ?? firstProduct?.size ?? '').toString().trim();
        const normalizedName = (name ?? Name ?? '').toString().trim();
        const normalizedLocation = (location ?? Location ?? '').toString().trim();
        const normalizedNumero = (numero ?? Numero ?? '').toString().trim();
        const productDoc = await Product.findById(productId).select('price');
        const productPrice = Number(productDoc?.price ?? firstProduct?.price ?? 0);
        const normalizedPrice = Number.isFinite(productPrice) ? productPrice * normalizedQuantity : 0;
        const isOffice = Boolean(office ?? false);
        const isDomicile = Boolean(domicile ?? !isOffice);

        if (!store || !user || !productId || !Number.isFinite(normalizedQuantity) || normalizedQuantity <= 0 || !normalizedSize) {
            return res.status(400).json({
                success: false,
                message: 'store, user, product, quantity, and size are required',
            });
        }

        const order = new Order({
            store,
            user,
            product: productId,
            quantity: normalizedQuantity,
            price: normalizedPrice,
            size: normalizedSize,
            name: normalizedName,
            location: normalizedLocation,
            numero: normalizedNumero,
            office: isOffice,
            domicile: isDomicile,
            confirmed: true,
            confirmationDate: new Date(),
        });

        const saved = await order.save();

        res.status(201).json({
            success: true,
            message: 'Order created successfully.',
            order: saved,
        });
    } catch (err) {
        res.status(500).json({
            success: false,
            message: err.message,
        });
    }
});

app.post("/GetAllOrders", async (req, res) => {
    try {
        const storeId = req.body.storeId ?? req.body.StoreId ?? req.body.store ?? req.body.Store;
        if (!storeId) {
            return res.status(400).json({
                success: false,
                message: "Store id is required",
            });
        }

        const orders = await Order.find({ store: storeId })
            .populate({ path: 'product', select: 'name price imageUrl' });
         

        res.json({
            success: true,
            count: orders.length,
            orders: orders
        });

    } catch (error) {
        console.error('Error fetching orders:', error);
        res.status(500).json({
            success: false,
            message: "Error fetching orders",
            error: error.message
        });
    }
});

app.post('/MigrateOrdersSchema', async (req, res) => {
    try {
        const fallbackSize = (req.body.defaultSize ?? 'M').toString().trim() || 'M';

        const [sizeResult, nameResult, locationResult, numeroResult] = await Promise.all([
            Order.updateMany(
                {
                    $or: [
                        { size: { $exists: false } },
                        { size: null },
                        { size: '' },
                    ],
                },
                { $set: { size: fallbackSize } }
            ),
            Order.updateMany(
                {
                    $or: [
                        { name: { $exists: false } },
                        { name: null },
                    ],
                },
                { $set: { name: '' } }
            ),
            Order.updateMany(
                {
                    $or: [
                        { location: { $exists: false } },
                        { location: null },
                    ],
                },
                { $set: { location: '' } }
            ),
            Order.updateMany(
                {
                    $or: [
                        { numero: { $exists: false } },
                        { numero: null },
                    ],
                },
                { $set: { numero: '' } }
            ),
        ]);

        const modified = {
            size: sizeResult.modifiedCount,
            name: nameResult.modifiedCount,
            location: locationResult.modifiedCount,
            numero: numeroResult.modifiedCount,
        };

        res.json({
            success: true,
            message: 'Order schema migration completed',
            fallbackSize,
            modified,
            totalModified: Object.values(modified).reduce((sum, value) => sum + value, 0),
        });
    } catch (error) {
        console.error('Error migrating orders schema:', error);
        res.status(500).json({
            success: false,
            message: 'Error migrating orders schema',
            error: error.message,
        });
    }
});

app.post("/UpdateOrderStatus", async (req, res) => {
    try {
        const orderId = req.body.orderId ?? req.body.OrderId;
        const nextStatus = (req.body.status ?? '').toString().toLowerCase();
        const order = await Order.findById(orderId);

        if (!order) {
            return res.json({
                success: false,
                message: "Order not found"
            });
        }

        const validStatuses = ['confirmed', 'prepared', 'shipped', 'delivered', 'canceled'];

        if (!validStatuses.includes(nextStatus)) {
            return res.json({
                success: false,
                message: "Invalid status, must be one of: " + validStatuses.join(', ')
            });
        }

        order.confirmed = nextStatus === 'confirmed' || nextStatus === 'prepared' || nextStatus === 'shipped' || nextStatus === 'delivered';
        order.prepared = nextStatus === 'prepared' || nextStatus === 'shipped' || nextStatus === 'delivered';
        order.shipped = nextStatus === 'shipped' || nextStatus === 'delivered';
        order.delivered = nextStatus === 'delivered';
        order.canceled = nextStatus === 'canceled';

        if (nextStatus === 'confirmed') {
            order.confirmationDate = new Date();
        }
        if (nextStatus === 'prepared') {
            order.preparationDate = new Date();
        }
        if (nextStatus === 'shipped') {
            order.shippingDate = new Date();
        }
        if (nextStatus === 'delivered') {
            order.deliveryDate = new Date();
        }
        if (nextStatus === 'canceled') {
            order.cancellationDate = new Date();
        }

        await order.save();

        res.json({
            success: true,
            message: "Order status updated successfully",
            order,
            status: nextStatus,
        });

    } catch (error) {
        console.error('Error updating order status:', error);
        res.status(500).json({
            success: false,
            message: "Error updating order status",
            error: error.message
        });
    }
});

// Admin endpoint: archive delivered orders older than retentionDays (days)
app.post('/Admin/ArchiveDelivered', async (req, res) => {
    try {
        const retentionDays = Number(req.body.retentionDays ?? req.query.retentionDays ?? 90);
        const count = await archiveDeliveredOrders(retentionDays);
        return res.json({ success: true, archived: count });
    } catch (err) {
        console.error('Admin ArchiveDelivered error:', err);
        return res.status(500).json({ success: false, message: err.message });
    }
});

// Admin endpoint: purge archived orders older than retentionDays (days)
app.post('/Admin/PurgeArchived', async (req, res) => {
    try {
        const retentionDays = Number(req.body.retentionDays ?? req.query.retentionDays ?? 365);
        const count = await purgeArchivedOrders(retentionDays);
        return res.json({ success: true, purged: count });
    } catch (err) {
        console.error('Admin PurgeArchived error:', err);
        return res.status(500).json({ success: false, message: err.message });
    }
});
