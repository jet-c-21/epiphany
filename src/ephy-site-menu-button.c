/* -*- Mode: C; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/*
 *  Copyright © 2025 Jan-Michael Brummer <jan.brummer@tabos.org>
 *
 *  This file is part of Epiphany.
 *
 *  Epiphany is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Epiphany is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Epiphany.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "ephy-site-menu-button.h"

struct _EphySiteMenuButton {
  AdwBin parent_instance;

  GtkWidget *menu_button;
  GtkWidget *zoom_level;
};

G_DEFINE_FINAL_TYPE (EphySiteMenuButton, ephy_site_menu_button, ADW_TYPE_BIN)

static void
ephy_site_menu_button_class_init (EphySiteMenuButtonClass *klass)
{
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);

  gtk_widget_class_set_template_from_resource (widget_class, "/org/gnome/epiphany/gtk/site-menu-button.ui");

  gtk_widget_class_bind_template_child (widget_class, EphySiteMenuButton, menu_button);
  gtk_widget_class_bind_template_child (widget_class, EphySiteMenuButton, zoom_level);
}

static void
ephy_site_menu_button_init (EphySiteMenuButton *self)
{
  gtk_widget_init_template (GTK_WIDGET (self));
}

GtkWidget *
ephy_site_menu_button_new (void)
{
  return g_object_new (EPHY_TYPE_SITE_MENU_BUTTON, NULL);
}

void
ephy_site_menu_button_set_zoom_level (EphySiteMenuButton *self,
                                      char               *zoom_level)
{
  gtk_label_set_text (GTK_LABEL (self->zoom_level), zoom_level);
}

void
ephy_site_menu_button_set_icon_name (EphySiteMenuButton *self,
                                     const char         *icon_name)
{
  gtk_menu_button_set_icon_name (GTK_MENU_BUTTON (self->menu_button), icon_name);
}

