#ifndef __ROOT_WIDGET_H__
#define __ROOT_WIDGET_H__

#include <gdk/gdk.h>
#include <gtk/gtk.h>
#include <glib-object.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef struct {
    gint width;
    gint height;
} CustomWidgetSize;

typedef struct _GtkCustomRootWidget {
    GtkWidget parent_instance;
  
    gint minimum_width;
    gint minimum_height;
    gint allocated_width;
    gint allocated_height;
    gboolean has_been_allocated;

    void *resize_callback_data;
    void (*resize_callback)(void*, CustomWidgetSize);

    GtkWidget *child;
} GtkCustomRootWidget;

#define GTK_CUSTOM_ROOT_WIDGET_TYPE (gtk_custom_root_widget_get_type())

G_DECLARE_FINAL_TYPE(GtkCustomRootWidget, gtk_custom_root_widget, GTK, CUSTOM_ROOT_WIDGET, GtkWidget)

GtkSizeRequestMode gtk_custom_root_widget_size_request_mode(GtkWidget *widget);

void gtk_custom_root_widget_measure(
    GtkWidget *widget,
    GtkOrientation orientation,
    int for_size,
    int *minimum,
    int *natural,
    int *minimum_baseline,
    int *natural_baseline
);

void gtk_custom_root_widget_allocate(
    GtkWidget *widget,
    int width,
    int height,
    int baseline
);

GtkWidget *gtk_custom_root_widget_new(void);

void gtk_custom_root_widget_set_child(GtkCustomRootWidget *self, GtkWidget *child);

void gtk_custom_root_widget_get_size(GtkCustomRootWidget *widget, gint *width, gint *height);

void gtk_custom_root_widget_set_minimum_size(
    GtkCustomRootWidget *self,
    gint minimum_width,
    gint minimum_height
);

void gtk_custom_root_widget_preempt_allocated_size(
    GtkCustomRootWidget *self,
    gint allocated_width,
    gint allocated_height
);

void gtk_custom_root_widget_set_resize_callback(
    GtkCustomRootWidget *self,
    void (*callback)(void*, CustomWidgetSize),
    void *data
);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ROOT_WIDGET_H__ */
