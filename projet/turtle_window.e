note
	description: "EiffelVision Widget TURTLE_WINDOW.%
		%The original version of this class was generated by EiffelBuild."
	generator: "EiffelBuild"
	date: "$Date: 2010-12-22 10:39:24 -0800 (Wed, 22 Dec 2010) $"
	revision: "$Revision: 85202 $"

class
	TURTLE_WINDOW

inherit
	TURTLE_WINDOW_IMP

feature {NONE} -- Initialization

	user_create_interface_objects
			-- Create any auxilliary objects needed for TURTLE_WINDOW.
			-- Initialization for these objects must be performed in `user_initialization'.
		do
			create double_buffer
			is_modified:=false
		end

	user_initialization
			-- Perform any initialization on objects created by `user_create_interface_objects'
			-- and from within current class itself.
		do
			turtle_area.expose_actions.extend (agent on_expose)
			turtle_area.resize_actions.extend (agent on_resize)
		end

feature -- Access

	turtle:TURTLE_TURTLE
		-- The turtle sprite
	floor:TURTLE_FLOOR
		-- The floor below the turtle.

	initialize_elements(a_turtle:TURTLE_TURTLE;a_floor:TURTLE_FLOOR)
		require
			Turtle_initialize:a_turtle/=Void
			Floor_initialize:a_floor/=Void
		do
			turtle:=a_turtle
			floor:=a_floor
			create timer.make_with_interval (1)
			timer.actions.extend (agent update_turtle_window)
		end

	on_resize(a_x,a_y,a_width,a_height:INTEGER)
		local
			memory_manager:MEMORY
		do
			floor.on_resize (a_width, a_height)
			create double_buffer.make_with_size (a_width, a_height)
			create memory_manager
			memory_manager.full_collect
			is_modified:=true
			update_turtle_window
		end
	on_expose(a_x,a_y,a_width,a_height:INTEGER)
		do
			is_modified:=true
			update_turtle_window
		end

	update_turtle_window
		do

			if turtle.is_modified or is_modified then
				turtle.internal_mutex.lock
				double_buffer.draw_pixmap (0, 0, floor.image)
				double_buffer.draw_pixmap ((turtle_area.width//2)-(turtle.image_ctrl.turtle_pixmap.width//2)+turtle.x, (turtle_area.height//2)-(turtle.image_ctrl.turtle_pixmap.height//2)+turtle.y, turtle.image_ctrl.turtle_pixmap)
				turtle_area.draw_pixmap (0, 0, floor.image)
				turtle_area.draw_pixmap (0, 0, double_buffer)
				turtle.clear_modified
				is_modified:=false
				turtle.internal_mutex.unlock
			end


		end

feature {NONE} -- Implementation

	select_save_item
			-- Called by `select_actions' of `mi_save'.
		local
			l_to_save:EV_PIXMAP
		do
			create l_to_save.make_with_size (turtle_area.width, turtle_area.height)
			l_to_save.draw_pixmap (0, 0, double_buffer)
			save_pixmap(l_to_save)
		end

	select_save_floor_item
			-- Called by `select_actions' of `mi_save_floor'.
		local
			l_to_save:EV_PIXMAP
		do
			create l_to_save.make_with_size (turtle_area.width, turtle_area.height)
			l_to_save.draw_pixmap (0, 0, floor.image)
			save_pixmap(l_to_save)
		end

	save_pixmap(l_pixmap:EV_PIXMAP)
		local
			l_file_save_dialog: EV_FILE_SAVE_DIALOG
		do
			Create l_file_save_dialog.make_with_title ("Save image")
			l_file_save_dialog.filters.extend (["*.png","PNG image"])
			l_file_save_dialog.filters.extend (["*.bmp","Bitmap image"])
			l_file_save_dialog.show_modal_to_window (Current)
			if not (l_file_save_dialog.file_name.count=0) then

				if l_file_save_dialog.file_title.as_lower.ends_with (".png") then
					l_pixmap.save_to_named_file (create {EV_PNG_FORMAT}, l_file_save_dialog.file_name)
				elseif l_file_save_dialog.file_title.as_lower.ends_with (".bmp") then
					l_pixmap.save_to_named_file (create {EV_BMP_FORMAT}, l_file_save_dialog.file_name)
				else
					l_pixmap.save_to_named_file (create {EV_PNG_FORMAT}, l_file_save_dialog.file_name+".png")
				end
			end
		end

	select_quit_item
			-- Called by `select_actions' of `mi_quit'.
		do
			destroy_and_exit_if_last
		end

	select_tutorial_item
			-- Called by `select_actions' of `mi_tutorial'.
		do
		end

	select_about_item
			-- Display the About dialog.
		local
			about_dialog: TURTLE_ABOUT_DIALOG
		do
			create about_dialog.make (turtle.image_ctrl.get_turtle_with_angle (0))
			about_dialog.show_modal_to_window (Current)
		end

	panel:TURTLE_PANEL

	timer:EV_TIMEOUT

	is_modified:BOOLEAN

	double_buffer:EV_PIXMAP

end
