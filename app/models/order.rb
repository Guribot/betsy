class Order < ApplicationRecord
  belongs_to :merchant
  has_many :orderproducts
  has_many :products, through: :orderproduct
end
