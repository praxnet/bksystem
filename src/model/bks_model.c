//      bks_model.c
//
//      Copyright 2011 Matthias Wauer <matthiaswauer@googlemail.com>
//
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.


#include <stdio.h>
#include <stdlib.h>

#include <Eina.h>
#include <Ecore.h>
#include <Ecore_File.h>

#include "Bks_Types.h"
#include "Bks_System.h"
#include "Bks_Model.h"
#include "Bks_Model_User_Account.h"
#include "Bks_Model_Product.h"
#include "Bks_Model_Sale.h"
#include "Bks_Model_Sql.h"
#include "Bks_Status.h" 
#include "Bks_Model_Path.h"


// Interface functions
void bks_model_controller_db_path_set(Eina_Stringshare *path) {

   _bks_model_path_set((char*)path);
}

void bks_model_init(void) {
   ecore_file_init();
   efreet_init();
   eina_lock_new(&mdl.lock);
   mdl.db_path = _bks_model_path_get();
#ifdef DEBUG
   fprintf(stderr, "Path: %s\n", mdl.db_path);
#endif
}

void bks_model_shutdown(void) {

   eina_lock_free(&mdl.lock);
   efreet_shutdown();
   ecore_file_shutdown();
}

Bks_Status bks_model_controller_user_accounts_alpha_get(Eina_List **user_accounts) {

   return _bks_model_sql_user_accounts_alpha_get(user_accounts);
}

Bks_Status bks_model_controller_user_accounts_fav_get(Eina_List **products, unsigned int limit) {

   return _bks_model_sql_user_accounts_fav_get(products, limit);
}

Bks_Status bks_model_controller_products_alpha_get(Eina_List **products) {

   return _bks_model_sql_products_alpha_get(products);
}

Bks_Status bks_model_controller_products_fav_get(Eina_List **products, unsigned int limit) {

   return _bks_model_sql_products_fav_get(products, limit);
}

Bks_Status bks_model_controller_commit_sale(const Bks_Model_Sale *sales) {
   
  return _bks_model_sql_commit_sale(sales); 
}

const Eina_List* bks_model_sales_from_user_since(const int uid UNUSED, const char *since UNUSED) {
   
   return NULL;
}

double bks_model_user_balance_get(const int uid UNUSED, const char *since UNUSED) {
   return 0;
}

void bks_model_create_bill_table(void) {
}
