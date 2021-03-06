#include <Eina.h>
#include <Evas.h>
#include <Elementary.h>
#include "Bks_Types.h"
#include "Bks_Model_Sale.h"
#include "Bks_System.h"
#include "Bks_Controller.h"
#include "Bks_Model.h"
#include "Bks_Ui.h"
#include "Bks_Ui_Private.h"
#include "Bks_Notification.h"


static void _ui_window_key(void *data, Evas *e, Evas_Object *obj, void *event_info);

static void _main_win_create(void)
{
   // new window - do the usual and give it a name and title
   ui.win = bks_ui_win_add();

   // add naviframe
   ui.naviframe = elm_naviframe_add(ui.win);
   EXPAND_AND_FILL(ui.naviframe);
   evas_object_show(ui.naviframe);
   evas_object_focus_set(ui.naviframe, EINA_TRUE);
   evas_object_event_callback_add(ui.naviframe, EVAS_CALLBACK_KEY_DOWN, _ui_window_key, NULL);
   elm_naviframe_content_preserve_on_pop_set(ui.naviframe, EINA_TRUE);
   // add object as a resize object for the window (controls window minimum
   // size as well as gets resized if window is resized)
   elm_win_resize_object_add(ui.win, ui.naviframe);

   // create notificaton
   ui.notification.note = elm_popup_add(ui.win);
   elm_popup_orient_set(ui.notification.note, ELM_POPUP_ORIENT_BOTTOM_RIGHT);
   elm_popup_allow_events_set(ui.notification.note, EINA_TRUE);
   evas_object_smart_callback_add(ui.notification.note, "block,clicked", _bks_ui_sale_notification_clicked, NULL);
   evas_object_smart_callback_add(ui.notification.note, "timeout", _bks_ui_sale_notification_timeout, NULL);

   //create, fill and add user_accounts ui elements
   ui.user_accounts.enp.content = user_accounts_page_add();
   evas_object_show(ui.user_accounts.enp.content);
   EXPAND_AND_FILL(ui.user_accounts.enp.content);
   ui.user_accounts.enp.eoi = elm_naviframe_item_push(ui.naviframe, "Konten", NULL, ui.user_accounts.enp.next_btn, ui.user_accounts.enp.content, NULL);

   //create and fill products
   ui.products.enp.content = products_page_add();
   evas_object_show(ui.products.enp.content);
   EXPAND_AND_FILL(ui.products.enp.content);
   ui.products.enp.eoi = elm_naviframe_item_push(ui.naviframe, "Produkte", ui.products.enp.prev_btn, ui.products.enp.next_btn, ui.products.enp.content, NULL);

   //create lock window
   ui.lock_window.win = elm_win_inwin_add(ui.win);
   ui.lock_window.content = elm_label_add(ui.lock_window.win);
   elm_object_text_set(ui.lock_window.content, "Daten werden aktualisiert.");
   evas_object_size_hint_align_set(ui.lock_window.content, 0.5, 0.5);
   elm_win_inwin_content_set(ui.lock_window.win, ui.lock_window.content);

   elm_naviframe_item_promote(ui.user_accounts.enp.eoi);

   //finally set size of window
   evas_object_resize(ui.win, 640, 480);
   //elm_win_fullscreen_set(ui.win, EINA_TRUE);
}

void bks_ui_init(int argc, char* argv[])
{
   char buf[PATH_MAX];

   // initialize Elementary
   elm_init(argc, argv);

   // set app relevant directories
   elm_app_info_set(main, "bksystem", "images/accounts/locked.png");

   // set overlay for ui elements
   snprintf(buf, (sizeof(buf) - 1), "%s/elm_overlay.edj", elm_app_data_dir_get());
   elm_theme_overlay_add(NULL, buf);
}

void bks_ui_shutdown(void)
{
   evas_object_del(ui.products.enp.content);
   ui.products.enp.content = NULL;
   evas_object_del(ui.user_accounts.enp.content);
   ui.user_accounts.enp.content = NULL;
   evas_object_del(ui.naviframe);
   ui.naviframe = NULL;
   evas_object_event_callback_del(ui.naviframe, EVAS_CALLBACK_KEY_DOWN, _ui_window_key);
   evas_object_del(ui.win);
   ui.win = NULL;

   elm_shutdown();
}

/**
 * @brief Indicates that the entire ui data is being refetched.
 */
void bks_ui_update_set(const Eina_Bool update)
{
#ifdef DEBUG
   printf("Jetzt sollte die UI %sbenutzbar sein.\n", (update ? "un" : ""));
#endif
   if (update)
     {
        ecore_thread_main_loop_begin();
        elm_win_inwin_activate(ui.lock_window.win);
        ecore_thread_main_loop_end();
     }
   else
     {
        ecore_thread_main_loop_begin();
        evas_object_hide(ui.lock_window.win);
        ecore_thread_main_loop_end();
     }
}

static void
_ui_window_key(void *data UNUSED, Evas *e UNUSED, Evas_Object *obj UNUSED, void *event)
{
   Evas_Event_Key_Down *ev = (Evas_Event_Key_Down*)event;
   Eina_Bool fullscreen_state;

   EINA_SAFETY_ON_NULL_RETURN(ev);

   if (!strncmp(ev->keyname, "Escape", sizeof("Escape")))
     {
        fullscreen_state = elm_win_fullscreen_get(ui.win);
        fullscreen_state ^= 1;
        elm_win_fullscreen_set(ui.win, fullscreen_state);
     }
}

void bks_ui_controller_main_show(void)
{
   _main_win_create();
   evas_object_show(ui.win);
}

void bks_ui_controller_singleton_display(void)
{
    _singleton_dialog_display();
}
