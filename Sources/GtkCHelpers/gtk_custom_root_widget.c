#include "gtk_custom_root_widget.h"

G_DEFINE_FINAL_TYPE(GtkCustomRootWidget, gtk_custom_root_widget, GTK_TYPE_WIDGET)

static void gtk_custom_root_widget_init(GtkCustomRootWidget *self) {}

static void gtk_custom_root_widget_class_init(GtkCustomRootWidgetClass *klass) {
    GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);
    widget_class->measure = gtk_custom_root_widget_measure;
    widget_class->size_allocate = gtk_custom_root_widget_allocate;
    widget_class->get_request_mode = gtk_custom_root_widget_size_request_mode;
}

GtkSizeRequestMode gtk_custom_root_widget_size_request_mode(GtkWidget *widget) {
    return GTK_SIZE_REQUEST_HEIGHT_FOR_WIDTH;
}

void gtk_custom_root_widget_measure(
    GtkWidget *widget,
    GtkOrientation orientation,
    int for_size,
    int *minimum,
    int *natural,
    int *minimum_baseline,
    int *natural_baseline
) {
    GtkCustomRootWidget *root_widget = GTK_CUSTOM_ROOT_WIDGET(widget);
    switch (orientation) {
        case GTK_ORIENTATION_HORIZONTAL:
            *minimum = root_widget->minimum_width;
            *natural = 0;
            break;
        case GTK_ORIENTATION_VERTICAL:
            *minimum = root_widget->minimum_height;
            *natural = 0;
            break;
    }
}

void gtk_custom_root_widget_allocate(
    GtkWidget *widget,
    int width,
    int height,
    int baseline
) {
    GtkCustomRootWidget *root_widget = GTK_CUSTOM_ROOT_WIDGET(widget);
    gtk_widget_allocate(root_widget->child, width, height, 0, NULL);

    root_widget->has_been_allocated = true;

    if (width == root_widget->allocated_width && height == root_widget->allocated_height) {
        return;
    }

    root_widget->allocated_width = width;
    root_widget->allocated_height = height;

    if (root_widget->resize_callback != NULL) {
        CustomWidgetSize size = { .width = width, .height = height };
        root_widget->resize_callback(root_widget->resize_callback_data, size);
    }
}

GtkWidget *gtk_custom_root_widget_new(void) {
    GtkCustomRootWidget *widget = g_object_new(GTK_CUSTOM_ROOT_WIDGET_TYPE, NULL);
    widget->child = NULL;
    widget->resize_callback = NULL;
    widget->resize_callback_data = NULL;
    widget->minimum_width = 0;
    widget->minimum_height = 0;
    widget->allocated_width = 0;
    widget->allocated_height = 0;
    widget->has_been_allocated = false;

    return GTK_WIDGET(widget);
}

void gtk_custom_root_widget_set_child(GtkCustomRootWidget *self, GtkWidget *child) {
    self->child = child;
    gtk_widget_set_parent(child, GTK_WIDGET(self));
}

void gtk_custom_root_widget_get_size(GtkCustomRootWidget *widget, gint *width, gint *height) {
    if (widget->has_been_allocated) {
        *width = widget->allocated_width;
        *height = widget->allocated_height;
    } else {
        *width = 0;
        *height = 0;
    }
}

void gtk_custom_root_widget_set_minimum_size(
    GtkCustomRootWidget *self,
    gint minimum_width,
    gint minimum_height
) {
    self->minimum_width = minimum_width;
    self->minimum_height = minimum_height;
    gtk_widget_queue_resize(GTK_WIDGET(self));
}

void gtk_custom_root_widget_preempt_allocated_size(
    GtkCustomRootWidget *self,
    gint allocated_width,
    gint allocated_height
) {
    self->allocated_width = allocated_width;
    self->allocated_height = allocated_height;
}

void gtk_custom_root_widget_set_resize_callback(
    GtkCustomRootWidget *self,
    void (*callback)(void*, CustomWidgetSize),
    void *data
) {
    self->resize_callback = callback;
    self->resize_callback_data = data;
}
