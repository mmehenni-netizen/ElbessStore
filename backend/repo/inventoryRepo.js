const Product = require('../model/Product_model.js');
const Store = require('../model/Store_model.js');
const cloudinary = require('cloudinary').v2;
const fs = require('fs');

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

    try {
        await cloudinary.uploader.destroy(publicId, { resource_type: 'image' });
        return true;
    } catch (error) {
        return false;
    }
}

async function getProductById(productId) {
    if (!productId) {
        return null;
    }

    return Product.findById(productId).lean();
}

async function updateProductById(productId, updates, file) {
    const product = await Product.findById(productId);
    if (!product) {
        return null;
    }

    if (typeof updates.name === 'string') product.name = updates.name.trim();
    if (typeof updates.description === 'string') product.description = updates.description.trim();
    if (updates.price !== undefined) product.price = Number(updates.price);
    if (updates.rating !== undefined) product.rating = Number(updates.rating);
    if (updates.totalQuantity !== undefined) product.totalQuantity = Number(updates.totalQuantity);
    if (typeof updates.category === 'string') product.category = updates.category.trim();
    if (typeof updates.gender === 'string') product.gender = updates.gender.trim();

    if (updates.sizeQuantities !== undefined) {
        let sizeQuantities = updates.sizeQuantities;
        if (typeof sizeQuantities === 'string') {
            try {
                sizeQuantities = JSON.parse(sizeQuantities);
            } catch (error) {
                sizeQuantities = [];
            }
        }

        if (Array.isArray(sizeQuantities)) {
            product.sizeQuantities = sizeQuantities
                .map((item) => ({
                    size: (item?.size ?? item?.Size ?? '').toString().trim(),
                    quantity: Number(item?.quantity ?? item?.Quantity ?? 0),
                }))
                .filter((item) => item.size && Number.isFinite(item.quantity));
        }
    }

    if (file && file.buffer) {
        if (Array.isArray(product.imageUrl)) {
            await Promise.all(product.imageUrl.map(async (storedPath) => {
                if (typeof storedPath === 'string' && storedPath.startsWith('http')) {
                    await deleteCloudinaryImage(storedPath);
                } else if (typeof storedPath === 'string' && storedPath.trim().length > 0) {
                    try {
                        if (fs.existsSync(storedPath)) {
                            fs.unlinkSync(storedPath);
                        }
                    } catch (error) {
                        // ignore local delete errors
                    }
                }
            }));
        }

        const uploaded = await new Promise((resolve, reject) => {
            const stream = cloudinary.uploader.upload_stream(
                {
                    folder: 'elbess-store/products',
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
        });

        product.imageUrl = uploaded?.secure_url ? [uploaded.secure_url] : [];
    }

    await product.save();
    return product.toObject();
}

async function deleteProductById(productId, uploadsDir) {
    const product = await Product.findById(productId);
    if (!product) {
        return { deleted: false, message: 'Product not found' };
    }

    if (product.store) {
        await Store.findByIdAndUpdate(product.store, { $pull: { products: productId } });
    }

    if (Array.isArray(product.imageUrl)) {
        await Promise.all(product.imageUrl.map(async (storedPath) => {
            if (!storedPath) return;

            if (typeof storedPath === 'string' && storedPath.startsWith('http')) {
                await deleteCloudinaryImage(storedPath);
                return;
            }

            if (typeof storedPath === 'string' && storedPath.startsWith('/uploads/')) {
                const imageFilePath = `${uploadsDir}\\${storedPath.split('/').pop()}`;
                try {
                    if (fs.existsSync(imageFilePath)) {
                        fs.unlinkSync(imageFilePath);
                    }
                } catch (error) {
                    // ignore local delete errors
                }
            }
        }));
    }

    await Product.findByIdAndDelete(productId);
    return { deleted: true };
}

module.exports = {
    getProductById,
    updateProductById,
    deleteProductById,
};
