const mongoose = require('mongoose')
const Schema =mongoose.Schema

const StoreSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  location: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    default: "",
  },
  activeProducts: {
    type: Number,
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

  rating: {
    type: Number,
    min: 0,
    max: 5,
    default: 0,
  },
  revenus: {
    type: Number,
    default: 0,
  },
  shippingTime: {
    type: Number,
    default: 3,
  },
  products: [
    {
      type: Schema.Types.ObjectId,
      ref: "Product",
    },
  ],
  orders: {
    type: Schema.Types.ObjectId,
    ref: "Order",
  },
  totalOrders: {
    type: Number,
    default: 0,
  },
  address: {
    type: String,
    required: true,
  },
  password: {
    type: String,
    required: true,
  },
  isEmailVerified: {
    type: Boolean,
    default: false,
  },
  emailVerificationToken: {
    type: String,
  },
  logo: {
    type: String,
    default: "/uploads/DefaultLogo.png",
  },
});

const Store = mongoose.model('Store',StoreSchema)

module.exports=Store
