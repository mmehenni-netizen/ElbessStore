const express = require('express')
const path = require('path'); 
const mongoose = require('mongoose')
const morgan = require('morgan')
const crypto = require('crypto')
const multer = require('multer'); 
const bcrypt = require('bcrypt')
const fs = require('fs');
const Order = require('./model/Order_model.js')
const Store  = require('./model/Store_model.js')
const Product  = require('./model/Product_model.js')
const { sendVerificationEmail } = require('./utils/sendEmail.js'); 
const { getAlreadyVerifiedPage, getSuccessPage, getErrorPage } = require('./templates/email-verification');

const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

// Upload method
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadsDir) 
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname);
        const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1E9) + ext;
        cb(null, uniqueName);
    }
});

const upload = multer({ storage: storage });


//initialize app
const app = express()

//middleware
app.use(express.json())
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));
app.use('/uploads', express.static(uploadsDir));

//url link
const Urldb =process.env.MONGODB_URI;

//connect to database
mongoose.connect(Urldb)
.then(result => {
    console.log('Connected to MongoDB');
    app.listen(3000, () => {
        console.log('Server is running on port 3000');
    });
})
.catch(err => console.log(err))


async function getStoreName({ id, address }) {
    if (id) {
        const storeById = await Store.findById(id).select('Name');
        return storeById?.Name ?? null;
    }

    if (address) {
        const normalizedAddress = address.trim().toLowerCase();
        if (!normalizedAddress) {
            return null;
        }

        const escapedAddress = normalizedAddress.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        const storeByAddress = await Store.findOne({
            Address: { $regex: `^\\s*${escapedAddress}\\s*$`, $options: 'i' },
        }).select('Name');
        return storeByAddress?.Name ?? null;
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

        const address = typeof rawAddress === 'string' ? rawAddress.trim() : '';
        const password = typeof rawPassword === 'string' ? rawPassword : '';

        if (!address || !password) {
            return res.status(400).json({
                find: false,
                message: "Address and Password are required",
            });
        }

        const escapedAddress = address.toLowerCase().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        const result = await Store.findOne({
            Address: { $regex: `^\\s*${escapedAddress}\\s*$`, $options: 'i' },
        });

        if (!result) {
            return res.json({
                find: false,
            });
        }

        const storedPassword = typeof result.Password === 'string' ? result.Password : '';
        const inputPasswords = [password, password.trim()].filter((value, index, arr) => value && arr.indexOf(value) === index);

        const isHashedPassword = storedPassword.startsWith('$2');
        const passwordMatches = isHashedPassword
            ? (await Promise.all(inputPasswords.map((candidate) => bcrypt.compare(candidate, storedPassword)))).some(Boolean)
            : inputPasswords.some((candidate) => storedPassword === candidate || storedPassword.trim() === candidate.trim());

        if (!passwordMatches) {
            return res.json({
                find: false,
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

app.post("/SignUp",upload.single('Logo'), async (req, res) => {

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

    Store.findOne({
        Address: { $regex: `^\\s*${address.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\s*$`, $options: 'i' },
}).then(async (result) => {
        if (result) { 
          res.json({
                creation: false,
                message: "Store already exists",
            });
        } else{

        const verificationToken = crypto.randomBytes(32).toString('hex');
        const logoPath = req.file ? `/uploads/${req.file.filename}` : "/uploads/DefaultLogo.png";
        
        const newStore= new Store({
            Address:address,
            Password:password,
      EmailVerificationToken: verificationToken,
      Name: req.body.Name,      
      Location: req.body.Location, 
      Description: req.body.Description ,
      Logo: logoPath 
    });

    newStore.save();
        const emailSent = await sendVerificationEmail(address, verificationToken);
    res.json({
      creation: true,
      message: "Store created successfully",
    });
        }
  
})
})


app.get("/verify-email", async (req, res) => {

    try {
        const { token } = req.query;

        if (!token) {
            return res.send(getErrorPage("Verification token is required"));
        }

        const store = await Store.findOne({ 
            EmailVerificationToken: token
        });

        if (!store) {
            return res.send(getErrorPage("Invalid or expired verification token"));
        }

        if (store.isEmailVerified) {
            return res.send(getAlreadyVerifiedPage(store.Address));
        }

        store.isEmailVerified = true;        
        await store.save();

        res.send(getSuccessPage(store.Address));

    } catch (error) {
        res.send(getErrorPage("Server error. Please try again later"));
    }
});

app.post("/AddProduct", upload.single('Image'), (req, res) => {
    
    const imagePath = req.file ? `/uploads/${req.file.filename}` : "";
    let sizeQuantities = req.body.SizeQuantities;
    sizeQuantities = JSON.parse(sizeQuantities);
    
    const newProduct = new Product({
        Name: req.body.Name,
        Price: req.body.Price,
        Rating: req.body.Rating,
        SizeQuantities: sizeQuantities, 
        Store: req.body.Store,
        Category:req.body.Category,
        ImageUrl: imagePath,
        TotalQuantity:req.body.TotalQuantity,
        Gender:req.body.Gender,
    });

    newProduct.save()
        .then(savedProduct => {
            return Store.findByIdAndUpdate(
                req.body.Store,  
                { $push: { products: savedProduct._id } }
            );
        })
        .then(updatedStore => {
            res.json({
                creation: true,
                message: "Product created successfully and added to store"
            });
            console.log("Product Added to DB and linked to Store");
        })
        .catch(err => {
            console.log(err);
            res.status(500).json({
                creation: false,
                message: "Error creating product",
                error: err.message
            });
        });
});


app.delete("/DeleteProduct", async (req, res) => {
    try {
        const productId = req.body.Id;
        const product = await Product.findById(productId);
        
        if (!product) {
            return res.json({
                deletion: false,
                message: "Product not found"
            });
        }
        
        const storeId = product.Store;     

        const updatedStore = await Store.findByIdAndUpdate(
            storeId,
            { $pull: { products: productId } },
            { new: true }
        );
        
        const deletedProduct = await Product.findByIdAndDelete(productId);
        
        if (product.ImageUrl) {
            const storedPath = product.ImageUrl;
            const imageFilePath = storedPath.startsWith('/uploads/')
                ? path.join(uploadsDir, path.basename(storedPath))
                : path.isAbsolute(storedPath)
                    ? storedPath
                    : path.join(__dirname, storedPath);

            fs.unlink(imageFilePath, (err) => {
                if (err) console.log("⚠️ Error deleting image:", err);
                else console.log("✅ Image deleted:", imageFilePath);
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
        const products = await Product.find({ Store: req.body.Id});
        
        res.json({
            success: true,
            count: products.length,
            products: products
        });

    } catch (error) {
        console.error('Error fetching store products:', error);
        res.status(500).json({
            success: false,
            message: "Error fetching products",
            error: error.message
        });
    }
},
 app.post("/AddOrder", async (req, res) => {
  try {
    const { store, type, products } = req.body
 
    if (!products || products.length === 0) {
      return res.status(400).json({ message: 'Order must have at least one product.' })
    }

     const totalPrice = products.reduce((sum, item) => {
      return sum + item.price * item.quantity
    }, 0)
 
    const order = new Order({
      store,
      user: req.user._id,   
      type: type || 'At Home',
      products,
      totalPrice,
      status: 'prepared',
    })
 
    const saved = await order.save()
 
    res.status(201).json({
      message: 'Order created successfully.',
      order: saved,
    })
  } catch (err) {
    res.status(500).json({ message: err.message })
  }
}
))

app.post("/GetAllOrders", async (req, res) => {
    try {
        const orders = await Order.find({ store: req.body.StoreId});
         

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

app.post("/UpdateOrderStatus", async (req, res) => {
    try {
        const order = await Order.findById(req.body.OrderId);

        if (!order) {
            return res.json({
                success: false,
                message: "Order not found"
            });
        }

        const validStatuses = ['prepared', 'confirmed', 'shipped', 'delivered', 'cancelled'];

        if (!validStatuses.includes(req.body.status)) {
            return res.json({
                success: false,
                message: "Invalid status, must be one of: " + validStatuses.join(', ')
            });
        }

        order.status = req.body.status;

        // if cancelled, save the reason
        if (req.body.status === 'cancelled') {
            order.cancelReason = req.body.cancelReason || '';
        }

        await order.save();

        res.json({
            success: true,
            message: "Order status updated successfully",
            order: order
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
