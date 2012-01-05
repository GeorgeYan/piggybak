require 'acts_as_variant/base'
require 'acts_as_orderer/base'
require 'application_helper'
require 'active_merchant'
require 'currency'

ActiveMerchant::Billing::Base.mode = :test

module Piggybak

  class Engine < Rails::Engine
    initializer "define rails_admin config" do |app|
      # RailsAdmin config file. Generated on December 21, 2011 13:04
      # See github.com/sferik/rails_admin for more informations

      RailsAdmin.config do |config|
        config.model Piggybak::Order do
          label "Order"
          navigation_label "Piggybak Orders"
          weight 1
          object_label_method :admin_label

          show do
            field :status
            field :total do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :tax_charge do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :total_due do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :created_at
            field :email
            field :phone
            field :user

            field :line_items
            field :billing_address
            field :shipping_address
            field :shipments
            field :payments
          end
          list do
            field :status
            field :total do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :created_at do
              #strftime_format "%d-%m-%Y"
            end
            field :user
          end
          edit do
            field :details do
              read_only true
              help "Autopopulated"
            end
            field :user do
              read_only do
                !bindings[:object].new_record?
              end
            end
            field :email
            field :phone
            field :billing_address do 
             help "Required"
            end
            field :shipping_address do
              help "Required"
            end
            field :line_items
            field :shipments
            field :payments
            field :actions do
              partial "actions"
              help "Click above to resend email with current order details."
            end
          end
        end
      
        config.model Piggybak::Address do
          label "Address"
          parent Piggybak::Order
          object_label_method :admin_label
          visible false
        end
      
        config.model Piggybak::LineItem do
          label "Line Item"
          object_label_method :admin_label
          visible false

          edit do
            field :variant
            field :quantity
            field :total do
              read_only true
              formatted_value do
                value ? "$%.2f" % value : '-'
              end
              help "This will automatically be calculated at the time of processing."
            end
          end
        end
      
        config.model Piggybak::Shipment do
          parent Piggybak::Order
          object_label_method :admin_label
          visible false

          edit do
            field :shipping_method
            field :status
            field :total do
              read_only true
              formatted_value do
                "$%.2f" % value
              end
              help "This will automatically be calculated at the time of processing."
            end
          end
        end
      
        config.model Piggybak::Payment do
          parent Piggybak::Order
          object_label_method :admin_label
          visible false

          edit do
            #field :details do
            #  read_only true
            #  help "Autopopulated"
            #end
            field :payment_method do
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :number do
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :month do
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :year do
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :verification_value do
              read_only do 
                !bindings[:object].new_record?
              end 
            end
            field :total do
              read_only true
              formatted_value do
                "$%.2f" % value
              end
              help "This will automatically be calculated at the time of processing."
            end
          end
        end
      
        config.model Piggybak::PaymentMethod do
          navigation_label "Piggybak Configuration"
          weight 2
          object_label_method :admin_label
          list do
            field :description
            field :active
          end
          edit do
            field :description do
              help "This is the label the user sees."
            end
            field :klass do
              label "Calculator"
            end
            field :active
            field :payment_method_values do
              label "Metadata"
            end
          end
        end

        config.model Piggybak::PaymentMethodValue do
          object_label_method :admin_label
          visible false
          edit do
            include_all_fields
            field :payment_method do
              visible false
            end
          end
        end
      
        config.model Piggybak::ShippingMethod do
          parent Piggybak::PaymentMethod
          object_label_method :admin_label
          edit do
            field :description do
              help "This is the label the user sees."
            end
            field :klass do
              label "Calculator"
            end
            field :active
            field :shipping_method_values do
              label "Metadata"
            end
          end
          list do
            field :description
            field :active
          end
        end
      
        config.model Piggybak::ShippingMethodValue do
          object_label_method :admin_label
          visible false
          edit do
            include_all_fields
            field :shipping_method do
              visible false
            end
          end
        end

        config.model Piggybak::TaxMethod do
          parent Piggybak::PaymentMethod
          object_label_method :admin_label
          edit do
            field :description
            field :klass do
              label "Calculator"
            end
            field :active
            field :tax_method_values do
              label "Metadata"
            end
          end
          list do
            field :description
            field :active
          end
        end
      
        config.model Piggybak::TaxMethodValue do
          object_label_method :admin_label
          visible false
          edit do
            include_all_fields
            field :tax_method do
              visible false
            end
          end
        end

        config.model Piggybak::Country do
          label "Countries"
          navigation_label "Piggybak Geodata"
          weight 3
          list do
            field :name
            field :abbr
          end
          edit do
            field :name
            field :abbr
          end
        end

        config.model Piggybak::State do
          parent Piggybak::Country
          label "States"
          list do
            field :name
            field :abbr
            field :country
          end
          edit do
            field :name
            field :abbr
            field :country
          end
        end
      
        config.model Piggybak::Variant do
          label "Variant"
          parent Piggybak::Order
          object_label_method :admin_label
          edit do
            field :item do
              read_only do
                !bindings[:object].new_record?
              end
            end
            include_all_fields
            field :unlimited_inventory do
              help "If true, backorders on this variant will be allowed, regardless of quantity on hand."
            end
          end
          list do
            field :description
            field :price
            field :quantity
            field :active
          end
        end
      end
    end
  end
end
