import 'package:start3x_app/exports.dart';

class ClientSetupScreen extends StatelessWidget {
  const ClientSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientSetupController());

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: AppColors.primaryBlue,
          centerTitle: true,
          title: const Text(
            'Details Setup',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please fill the required client details to proceed.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // SECTION 1: CLIENT INFO
                _buildSectionCard(
                  title: '1.  INFO',
                  children: [
                    _buildFormRow('Legal Name:', controller.legalNameController, 'Enter Legal Name'),
                    _buildFormRow('Company Name:', controller.companyNameController, 'Enter Company Name'),
                    _buildFormRow('GST Name:', controller.gstNameController, 'Enter GST Name'),
                    _buildFormRow('GST Number:', controller.gstNumberController, 'Enter GST Number'),
                    _buildFormRow('Phone Number:', controller.phoneController, 'Enter Phone Number', keyboardType: TextInputType.phone),
                    _buildFormRow('Targeted Location:', controller.targetedLocationController, 'Enter Location'),
                    const SizedBox(height: 10),
                    const Text(
                      'Full Address:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: controller.fullAddressController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter complete address here...',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // SECTION 2: ON-GRID PRICES
                _buildSectionCard(
                  title: '3. ON-GRID PRICES',
                  children: [
                    _buildFormRow('On-Grid 3 kW:', controller.onGrid3kWController, 'Price (₹)', keyboardType: TextInputType.number),
                    _buildFormRow('On-Grid 4 kW:', controller.onGrid4kWController, 'Price (₹)', keyboardType: TextInputType.number),
                    _buildFormRow('On-Grid 5 kW:', controller.onGrid5kWController, 'Price (₹)', keyboardType: TextInputType.number),
                  ],
                ),

                const SizedBox(height: 20),

                // SECTION 3: HYBRID PRICES
                _buildSectionCard(
                  title: '4. HYBRID PRICES',
                  children: [
                    _buildFormRow('Hybrid 3 kW:', controller.hybrid3kWController, 'Price (₹)', keyboardType: TextInputType.number),
                    _buildFormRow('Hybrid 4 kW:', controller.hybrid4kWController, 'Price (₹)', keyboardType: TextInputType.number),
                    _buildFormRow('Hybrid 5 kW:', controller.hybrid5kWController, 'Price (₹)', keyboardType: TextInputType.number),
                  ],
                ),

                const SizedBox(height: 20),

                // SECTION 4: HARDWARE SPECS
                _buildSectionCard(
                  title: '5. HARDWARE SPECS',
                  children: [
                    _buildFormRow('Inverter Name:', controller.inverterSpecController, 'Enter Inverter Name'),
                    _buildFormRow('Battery Name:', controller.batterySpecController, 'Enter Battery Name'),
                  ],
                ),

                const SizedBox(height: 28),

                // SUBMIT BUTTON
                CustomButton(
                  text: 'SAVE CLIENT DETAILS',
                  color: AppColors.primaryBlue,
                  radius: 12,
                  buttonHeight: 52,
                  onPressed: controller.submitClientInfo,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
              letterSpacing: 0.5,
            ),
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormRow(
    String label,
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
