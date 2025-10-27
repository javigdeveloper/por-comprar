class Item < ApplicationRecord
  enum :status, [ :to_buy, :bought, :archived ]

  validate :custom_name_validations

  def custom_name_validations
    if name.blank?
      errors.add(:base, "El artículo no puede estar vacío")
    elsif name.length > 50
      errors.add(:base, "El artículo es demasiado largo (máx. 50 caracteres)")
    else
      normalized_name = name.strip.downcase

      duplicate = Item.where("LOWER(name) = ?", normalized_name)
      duplicate = duplicate.where.not(id: id) if persisted?

      if duplicate.exists?
        errors.add(:base, "El artículo ya existe en esta u otra lista")
      end
    end
  end
end
