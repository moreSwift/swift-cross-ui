#include "gtk_custom_root_widget.h"

G_DEFINE_TYPE(GtkCustomRootWidget, gtk_custom_root_widget, GTK_TYPE_BIN)

static void gtk_custom_root_widget_init(GtkCustomRootWidget *self) {
    gtk_widget_set_has_window(GTK_WIDGET(self), FALSE);
}

static void gtk_custom_root_widget_class_init(GtkCustomRootWidgetClass *klass) {
    GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);
    widget_class->get_preferred_width = gtk_custom_root_widget_get_preferred_width;
    widget_class->get_preferred_height = gtk_custom_root_widget_get_preferred_height;
    widget_class->size_allocate = gtk_custom_root_widget_size_allocate;
    widget_class->get_request_mode = gtk_custom_root_widget_size_request_mode;
    widget_class->realize = gtk_custom_root_widget_realize;
}

void gtk_custom_root_widget_realize(GtkWidget *widget) {
    GtkWidgetClass *parent_class = GTK_WIDGET_CLASS(gtk_custom_root_widget_parent_class);
    parent_class->realize(widget);

    GtkCustomRootWidget *root_widget = GTK_CUSTOM_ROOT_WIDGET(widget);
    if (root_widget->child) {
        gtk_widget_realize(root_widget->child);
    }
}

GtkSizeRequestMode gtk_custom_root_widget_size_request_mode(GtkWidget *widget) {
    return GTK_SIZE_REQUEST_HEIGHT_FOR_WIDTH;
}

int max(int a, int b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

void gtk_custom_root_widget_get_preferred_width(
    GtkWidget *widget,
    int *minimum,
    int *natural
) {
    GtkCustomRootWidget *root_widget = GTK_CUSTOM_ROOT_WIDGET(widget);
    *minimum = root_widget->minimum_width;
    *natural = max(root_widget->natural_width, root_widget->minimum_width);
}

void gtk_custom_root_widget_get_preferred_height(
    GtkWidget *widget,
    int *minimum,
    int *natural
) {
    GtkCustomRootWidget *root_widget = GTK_CUSTOM_ROOT_WIDGET(widget);
    *minimum = root_widget->minimum_height;
    *natural = max(root_widget->natural_height, root_widget->minimum_height);
}

void gtk_custom_root_widget_size_allocate(
    GtkWidget *widget,
    GtkAllocation *allocation
) {
    GtkCustomRootWidget *root_widget = GTK_CUSTOM_ROOT_WIDGET(widget);
    gtk_widget_set_allocation(widget, allocation);
    gtk_widget_size_allocate(root_widget->child, allocation);

    if (allocation->width == root_widget->allocated_width && allocation->height == root_widget->allocated_height) {
        return;
    }

    root_widget->allocated_width = allocation->width;
    root_widget->allocated_height = allocation->height;
    root_widget->has_been_allocated = TRUE;

    if (root_widget->resize_callback != NULL) {
        CustomWidgetSize size = { .width = allocation->width, .height = allocation->height };
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
    widget->natural_width = 0;
    widget->natural_height = 0;
    widget->allocated_width = 0;
    widget->allocated_height = 0;
    widget->has_been_allocated = FALSE;

    return GTK_WIDGET(widget);
}

void gtk_custom_root_widget_set_child(GtkCustomRootWidget *self, GtkWidget *child) {
    if (self->child != NULL) {
        gtk_container_remove(GTK_CONTAINER(self), self->child);
    }
    self->child = child;
    gtk_container_add(GTK_CONTAINER(self), child);
}

void gtk_custom_root_widget_get_size(GtkCustomRootWidget *widget, gint *width, gint *height) {
    if (widget->has_been_allocated || widget->natural_width == 0 || widget->natural_height == 0) {
        *width = widget->allocated_width;
        *height = widget->allocated_height;
    } else {
        *width = widget->natural_width;
        *height = widget->natural_height;
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

void gtk_custom_root_widget_set_natural_size(
    GtkCustomRootWidget *self,
    gint natural_width,
    gint natural_height
) {
    self->natural_width = natural_width;
    self->natural_height = natural_height;
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
