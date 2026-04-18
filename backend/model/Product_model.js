const mongoose = require('mongoose')
const Schema =mongoose.Schema

const ProductSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
  },
  rating: {
    type: Number,
    min: 0,
    max: 5,
    default: 0,
  },
  rates: [
    {
      user: {
        type: Schema.Types.ObjectId,
        ref: "User",
      },
      rate: {
        type: Number,
        min: 0,
        max: 5,
        default: 0,
      },
    },
  ],
  totalQuantity: {
    type: Number,
    required: true,
  },
  sizeQuantities: [
    {
      size: {
        type: String,
        required: true,
        enum: ["S", "M", "L", "XL"],
      },
      quantity: {
        type: Number,
        required: true,
        min: 0,
      },
    },
  ],
  store: {
    type: Schema.Types.ObjectId,
    ref: "Store",
  },
  imageUrl: {
    type: String,
    default: "default-product-image.jpg",
  },
  category: {
    type: String,
    required: true,
  },
  gender: {
    type: String,
    required: true,
  },
});

const Product = mongoose.model('Product',ProductSchema)

module.exports=Product
