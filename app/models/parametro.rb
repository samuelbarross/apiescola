class Parametro < ApplicationRecord
  audited on: [:update, :destroy]
end
