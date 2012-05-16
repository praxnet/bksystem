#include <Evas.h>
#include "Bks_System.h"
#include "Bks_Controller.h"

static void _db_path_selected(void *data, Evas_Object *obj UNUSED, void *event_info)
{
   Eina_Stringshare *path = (Eina_Stringshare*)event_info;
   Evas_Object *inwin = (Evas_Object*)data;

   bks_controller_ui_db_path_set(path);
   evas_object_del(inwin);
}

static void _bks_ui_controller_db_path_get(void *data UNUSED)
{
   Evas_Object *inwin, *fs;

   printf("Available threads: %d\n", ecore_thread_available_get());

   elm_need_ethumb();

   inwin = elm_win_inwin_add(ui.win);
   fs = elm_fileselector_add(inwin);
   elm_fileselector_expandable_set(fs, EINA_FALSE);
   elm_fileselector_path_set(fs, getenv("HOME"));
   evas_object_size_hint_weight_set(fs, EVAS_HINT_EXPAND, EVAS_HINT_EXPAND);
   //evas_object_size_hint_align_set(fs, 0.5, 0.5);
   evas_object_size_hint_align_set(fs, EVAS_HINT_FILL, EVAS_HINT_FILL);
   evas_object_smart_callback_add(fs, "done", _db_path_selected, inwin);
   evas_object_show(fs);

   elm_win_inwin_content_set(inwin, fs);
   elm_win_inwin_activate(inwin);

   printf("Created and displaying \"file open\" dialog.\n");
}

void bks_ui_controller_db_path_get(void)
{
   ecore_main_loop_thread_safe_call_async(_bks_ui_controller_db_path_get, NULL);
}
