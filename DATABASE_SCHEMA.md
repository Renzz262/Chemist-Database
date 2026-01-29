Database Schema
```mermaid
erDiagram
    MEDICATION_CATEGORIES {
        int category_id PK
        varchar category_name
        text description
    }

    MEDICATIONS {
        int medication_id PK
        varchar medication_name
        int category_id FK
        varchar dosage_form
        decimal unit_price
        int reorder_level
    }

    INVENTORY {
        int inventory_id PK
        int medication_id FK
        varchar batch_number
        int quantity_in_stock
        date expiry_date
        varchar status
    }

    SUPPLIERS {
        int supplier_id PK
        varchar supplier_name
        varchar contact_phone
        varchar email
    }

    PURCHASES {
        int purchase_id PK
        int supplier_id FK
        date purchase_date
        decimal total_cost
    }

    PURCHASE_DETAILS {
        int purchase_detail_id PK
        int purchase_id FK
        int medication_id FK
        int quantity_purchased
        decimal cost_price
    }

    SALES {
        int sale_id PK
        datetime sale_date
        decimal total_amount
    }

    SALE_DETAILS {
        int sale_detail_id PK
        int sale_id FK
        int medication_id FK
        int quantity_sold
        decimal selling_price
    }

    MEDICATION_CATEGORIES ||--|{ MEDICATIONS : "categorizes"
    MEDICATIONS ||--|{ INVENTORY : "stocked in"
    SUPPLIERS ||--|{ PURCHASES : "supplies"
    PURCHASES ||--|{ PURCHASE_DETAILS : "contains"
    MEDICATIONS ||--|{ PURCHASE_DETAILS : "listed in"
    SALES ||--|{ SALE_DETAILS : "includes"
    MEDICATIONS ||--|{ SALE_DETAILS : "sold as"
```

Table Descriptions

 The medication_categories table -
Stores different categories of medications (e.g., Antibiotics, Painkillers).

The medications table -
Stores details of each medication, linked to a category.

The inventory table -
Tracks stock levels, batch numbers, and expiry dates for medications.

The suppliers table -
Information about suppliers who provide medications.

The purchases table -
Records purchase transactions from suppliers.

The purchase_details table -
Line items for each purchase, linking medications to the purchase record.

The sales table -
Records sales transactions to customers.

The sale_details table -
Line items for each sale, detailing which medications were sold.
