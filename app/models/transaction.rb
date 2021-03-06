# A transaction handles the purchase process of an artucle.
#
# == License:
# Fairnopoly - Fairnopoly is an open-source online marketplace.
# Copyright (C) 2013 Fairnopoly eG
#
# This file is part of Fairnopoly.
#
# Fairnopoly is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Fairnopoly is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Fairnopoly.  If not, see <http://www.gnu.org/licenses/>.
#
class Transaction < ActiveRecord::Base
  extend Enumerize

  has_one :article
  attr_accessible :type, :selected_transport, :selected_payment, :tos_accepted

  #@todo remove duplication with data in Article::Attributes
  enumerize :selected_transport, in: Article::TRANSPORT_TYPES
  enumerize :selected_payment, in: Article::PAYMENT_TYPES

  delegate :title, :seller, :selectable_transports, :selectable_payments,
           :transport_provider, :transport_price, :payment_cash_on_delivery_price,
           :basic_price, :price, :vat, :vat_price, :price_without_vat,
           :total_price,
           to: :article, prefix: true

  # Edit can be called with GET params. If they are valid, it renders a different
  # view to show the final sales price. This method is called to validates if the
  # params are valid.
  #
  # @api public
  # @param params [Hash] The GET parameters
  # @return [Boolean]
  def edit_params_valid? params
    unless params["transaction"] && params["transaction"]["selected_payment"] && params["transaction"]["selected_transport"]
      return false
    end

    supports?("transport", params["transaction"]["selected_transport"]) && supports?("payment", params["transaction"]["selected_payment"])
  end

  # Get transport options that were selected by seller
  #
  # @api public
  # @return [Array] Array in 2 levels with option name and it's localization
  def selected_transports
    selected "transport"
  end

  # Get payment options that were selected by seller
  #
  # @api public
  # @return [Array] Array in 2 levels with option name and it's localization
  def selected_payments
    selected "payment"
  end

  private
  # Check if seller allowed [transport/payment] type of [type] for the associated
  # article. Also sets error message.
  #
  # @api private
  # @param attribute [String] ATM: payment or transport
  # @param type [String] The type to check
  # @return [Boolean]
  def supports? attribute, type
    if self.article.send "#{attribute}_#{type}?"
      true
    else
      errors["selected_#{attribute}".to_sym] = I18n.t "transaction.notices.#{attribute}_not_supported"
      false
    end
  end

  # Get attribute options that were selected on transaction's article
  #
  # @api private
  # @param attribute [String] "transport" or "payment" (enums that have a counter part in the article model)
  # @return [Array] Array in 2 levels with enum option name and it's localization
  def selected attribute
    selectables = send("article_selectable_#{attribute}s")
    Transaction.send("selected_#{attribute}").options.select { |e| selectables.include? e[1].to_sym }
  end
end
