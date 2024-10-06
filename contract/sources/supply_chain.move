    module supply_chain_addr :: supply_chain {
        use aptos_std::coin::{transfer};
        use aptos_framework::aptos_coin::AptosCoin;
        use std :: vector;
        use std::signer; 
        use std::option::Option;
        use std :: option;
        use std::string::String;

        struct Counter has key {
            value: u64,
        }

        public entry fun init_counter(account: &signer) {
            assert!(!exists<Counter>(signer::address_of(account)), 1);  // Ensure the counter doesn't already exist
            move_to(account, Counter { value: 0 });
        }

        public entry fun increment(account: &signer) acquires Counter {
            let counter = borrow_global_mut<Counter>(signer::address_of(account));
            counter.value = counter.value + 1;
        }

        public fun get_value(account: &signer): u64 acquires Counter {
            let counter = borrow_global<Counter>(signer::address_of(account));
            counter.value
        }

        struct Manufacturer has store,key,copy {
            account: address,
            name: String
        }
        struct Consumer has store {
            account: address,
            purchases: vector<u64>, 
        }
        struct Product has store,drop,copy {
            id: u64,
            name: String,
            manufacturer : address,
            batch_number : u64,
            manufacture_date: u64, 
            price: u64
        }
        struct ManufacturerProducts  has key{
            products: vector<Product>,
        }
        struct AllManufacturers has key {
            manufacturers: vector<address>,
        }
        public fun init_all_manufacturers(account: &signer) {
            assert!(!exists<AllManufacturers>(@0x1), 1);  // If already initialized, return error 1
            move_to(account, AllManufacturers {
                manufacturers: vector::empty<address>(),
            });
        }

        #[view]
        public fun test(): u64 {
            let i: u64 = 42;
            i
        }

        public fun init_manufacturer(account: &signer, manufacturer_name: String)acquires AllManufacturers {
            let address = signer::address_of(account);
            assert!(!exists<Manufacturer>(address), 2); // Manufacturer already exists
            
            move_to(account, Manufacturer {
                account: address,  
                name: manufacturer_name  
            });
            let global_manufacturers = borrow_global_mut<AllManufacturers>(@0x1);
            vector::push_back(&mut global_manufacturers.manufacturers, address);

            // Initialize their product list
            init_manufacturer_products(account);
        }
        
        public fun init_manufacturer_products(account: &signer){
            move_to(account,ManufacturerProducts{
                products: vector :: empty<Product>(),
            });
        }
        public fun create_product (
            account: &signer,
            product_id : u64,
            product_name: String,
            batch_number: u64, 
            manufacture_date: u64, 
            product_price: u64
        )acquires ManufacturerProducts{
            let manufacturer_address = signer:: address_of(account);
            let manufacturer_products=borrow_global_mut<ManufacturerProducts>(manufacturer_address);
            let new_product= Product{
                id:product_id,
                name: product_name,
                manufacturer: manufacturer_address,
                batch_number: batch_number,
                manufacture_date: manufacture_date,
                price: product_price,
            };
            vector::push_back(&mut manufacturer_products.products, new_product);
        }
        public fun get_product(manufacturer_address: address, product_id: u64): Option<Product> acquires ManufacturerProducts  {
            // Borrow the global ManufacturerProducts object associated with the manufacturer address
            let manufacturer_products = borrow_global<ManufacturerProducts>(manufacturer_address);
            
            // Get a reference to the vector of products
            let products = &manufacturer_products.products;

            // Manually loop through the products to find the one with the given product_id
            let i : u64 = 0;
            while (i < vector::length(products)) {
                let product = vector::borrow(products, i);
                
                // Check if the current product's ID matches the requested product_id
                if (product.id == product_id) {
                    // Return the found product wrapped in Option::some
                    return option::some(*product) // Dereference to return a copy of the product
                };
                i = i + 1; // Increment index for the next iteration
            };

            // If no matching product is found, return None
            option::none()
        }

        public fun purchase_product(
            account: &signer,
            manufacturer_address: address,
            product_id: u64,
        ) acquires ManufacturerProducts  {
            // Borrow the global ManufacturerProducts object associated with the manufacturer address
            let manufacturer_products = borrow_global_mut<ManufacturerProducts>(manufacturer_address);
            
            // Get a mutable reference to the products vector
            let products = &mut manufacturer_products.products;

            // Initialize index and found flag
            let index: u64 = 0;
            let found: bool = false;

            // Loop through the products to find the one with the given product_id
            while (index < vector::length(products)) {
                let product = vector::borrow(products, index);
                
                // Check if the current product's ID matches the requested product_id
                if (product.id == product_id) {
                    found = true; // Set found flag to true
                    break // Exit the loop when found
                };
                index = index + 1; // Increment index for the next iteration
            };

            // Assert that the product was found
            assert!(found, 3);

            // Get the product from the vector and make the purchase
            let product = vector::borrow(products, index);
            assert!(aptos_std::coin::balance<AptosCoin>(signer::address_of(account)) >= product.price, 4); // 4 error is for buyer funds checking
            transfer<AptosCoin>(account, manufacturer_address, product.price);
            vector::remove(products, index);
        }


    }

// Error Code 1: Manufacturer does not exist (in init_manufacturer and purchase_product).
// Error Code 2: Product not found for purchase (in purchase_product).
// Error Code 3: Insufficient funds for purchase (in purchase_product during fund transfer).
// Error Code 4: Insufficient funds for purchase (in purchase_product during fund transfer).
