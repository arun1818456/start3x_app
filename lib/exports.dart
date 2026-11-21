// Dart & External Packages
export 'dart:convert';
// dart:io is not available on web — only import it in files that
// are guarded with `kIsWeb` or conditional imports.
// export 'dart:io' hide HeaderValue;
export 'package:flutter/material.dart';
export 'package:get/get.dart' hide Response, MultipartFile, FormData;
export 'package:get_storage/get_storage.dart';
export 'package:http/http.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:google_sign_in/google_sign_in.dart';

// App Constants
export 'package:start3x_app/constants/api_constant.dart';
export 'package:start3x_app/constants/app_fonts.dart';
export 'package:start3x_app/constants/colors.dart';
export 'package:start3x_app/constants/image_constants.dart';
export 'package:start3x_app/constants/local_keys.dart';
export 'package:start3x_app/constants/text_styles.dart';
export 'package:start3x_app/constants/validations.dart';

// App Services
export 'package:start3x_app/services/api_handler.dart';
export 'package:start3x_app/services/app_exception.dart';
export 'package:start3x_app/services/socket_controller.dart';
export 'package:start3x_app/services/auth_services.dart';
export 'package:start3x_app/services/notification_services.dart';

// App Mixin
export 'package:start3x_app/mixin/base_class.dart';
export 'package:start3x_app/mixin/responsive_helper.dart';

// App Models
export 'package:start3x_app/admin/models/access_model.dart';
export 'package:start3x_app/app/models/group_message_model.dart';
export 'package:start3x_app/app/models/insight_item_model.dart';
export 'package:start3x_app/app/models/lead_model.dart';
export 'package:start3x_app/app/models/lead_response_model.dart';
export 'package:start3x_app/app/models/to_do_item_model.dart';
export 'package:start3x_app/app/models/user_model.dart';

// App Screens & Controllers
export 'package:start3x_app/admin/access_control/access_control_controller.dart';
export 'package:start3x_app/admin/access_control/access_control_screen.dart';
export 'package:start3x_app/admin/client_management_controller.dart';
export 'package:start3x_app/admin/admin_dashboard_screen.dart';
export 'package:start3x_app/admin/client_details_screen/client_detail_controller.dart';
export 'package:start3x_app/admin/client_details_screen/client_detail_screen.dart';
export 'package:start3x_app/admin/clients_screen/clients_controller.dart';
export 'package:start3x_app/admin/clients_screen/clients_screen.dart';
export 'package:start3x_app/auth/client_setup/client_setup_controller.dart';
export 'package:start3x_app/auth/client_setup/client_setup_screen.dart';
export 'package:start3x_app/auth/login/login_controller.dart';
export 'package:start3x_app/auth/login/login_screen.dart';
export 'package:start3x_app/auth/splash/splash_controller.dart';
export 'package:start3x_app/auth/splash/splash_binding.dart';
export 'package:start3x_app/auth/splash/splash_screen.dart';
export 'package:start3x_app/app/screens/bottom_bar/bottom_bar.dart';
export 'package:start3x_app/app/screens/bottom_bar/bottom_controller.dart';
export 'package:start3x_app/app/screens/group/group_controller.dart';
export 'package:start3x_app/app/screens/group/group_screen.dart';
export 'package:start3x_app/app/screens/home/final_call_data/final_screen.dart';
export 'package:start3x_app/app/screens/home/final_call_data/final_screen_controller.dart';
export 'package:start3x_app/app/screens/home/calls_response/call_response_controller.dart';
export 'package:start3x_app/app/screens/home/calls_response/call_response_screen.dart';
export 'package:start3x_app/app/screens/home/calling/calling_controller.dart';
export 'package:start3x_app/app/screens/home/calling/calling_screen.dart';
export 'package:start3x_app/app/screens/home/home_controller.dart';
export 'package:start3x_app/app/screens/home/home_screen.dart';
export 'package:start3x_app/app/screens/insights/insights_controller.dart';
export 'package:start3x_app/app/screens/insights/insights_screen.dart';
export 'package:start3x_app/app/screens/insights/insight_folder_screen.dart';
export 'package:start3x_app/app/screens/to_do/task_controller.dart';
export 'package:start3x_app/app/screens/to_do/to_do_screen.dart';
export 'package:start3x_app/app/screens/team/team_controller.dart';
export 'package:start3x_app/app/screens/team/team_screen.dart';

// App Routes
export 'package:start3x_app/routes/routes.dart';
export 'package:start3x_app/routes/pages.dart';

// App Widgets
export 'package:start3x_app/widgets/button.dart';
export 'package:start3x_app/widgets/common_dialogs.dart';
export 'package:start3x_app/widgets/deal_closed_prompt_dialog.dart';
export 'package:start3x_app/widgets/full_screen_loader.dart';
export 'package:start3x_app/widgets/lead_card.dart';
export 'package:start3x_app/widgets/side_menu.dart';
export 'package:start3x_app/widgets/text_field.dart';
export 'package:start3x_app/widgets/responsive_layout.dart';
export 'package:start3x_app/widgets/footer_widget.dart';
export 'package:start3x_app/widgets/logo_text_widget.dart';
export 'package:start3x_app/widgets/profile_name_widget.dart';

// Web Marketing Landing Page & Web Features (lib/web)
export 'package:start3x_app/web/view/home/home_screen.dart';
export 'package:start3x_app/web/view/home/home_screen_controller.dart';
export 'package:start3x_app/web/view/invoice_generator/invoice_generator.dart';
export 'package:start3x_app/web/view/invoice_generator/invoice_generator_controller.dart';
export 'package:start3x_app/web/view/profile/profile_screen.dart';
export 'package:start3x_app/web/view/profile/profile_controller.dart';
