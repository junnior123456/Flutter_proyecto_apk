import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/services/donation_service.dart';
import '../../../../core/utils/logger.dart';

/// 💰 Pantalla de Donaciones con Yape
class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 📱 Datos de Yape
  final String yapeNumber = '987654321'; // Tu número de Yape
  final String yapeName = 'PawFinder';
  
  // 💵 Montos sugeridos
  final List<int> suggestedAmounts = [5, 10, 20, 50, 100];
  int? selectedAmount;
  
  // 🔄 Estado de carga
  bool isLoading = false;
  
  // 💰 Servicio de donaciones
  final DonationService _donationService = DonationService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B2C91), // Morado Yape
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Donaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🐾 Header con logo
                _buildHeader(),
                
                const SizedBox(height: 30),
                
                // 💳 Tarjeta principal con QR
                _buildYapeCard(),
                
                const SizedBox(height: 30),
                
                // 💵 Montos sugeridos
                _buildSuggestedAmounts(),
                
                const SizedBox(height: 30),
                
                // 📋 Instrucciones
                _buildInstructions(),
                
                const SizedBox(height: 30),
                
                // 🎯 Impacto de las donaciones
                _buildImpactSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🐾 Header con mensaje motivacional
  Widget _buildHeader() {
    return Column(
      children: [
        // Icono de corazón animado
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        const Text(
          '¡Ayuda a salvar vidas!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 10),
        
        Text(
          'Tu donación ayuda a rescatar y cuidar\nmascotas en situación de riesgo',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 💳 Tarjeta principal con QR de Yape
  Widget _buildYapeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo de Yape
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF6B2C91),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9A5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'S/',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'yape',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          
          // QR Code (placeholder - en producción usar qr_flutter)
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                // QR Code simulado
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF6B2C91), width: 3),
                  ),
                  child: Stack(
                    children: [
                      // Patrón de QR simulado
                      Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: 200,
                          color: Colors.grey[300],
                        ),
                      ),
                      // Logo de Yape en el centro
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B2C91),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'S/',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D9A5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Número de Yape
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_android, color: Color(0xFF6B2C91)),
                      const SizedBox(width: 8),
                      Text(
                        yapeNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B2C91),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        color: const Color(0xFF6B2C91),
                        onPressed: () => _copyToClipboard(yapeNumber),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  yapeName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Botón de realizar donación
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: ElevatedButton(
              onPressed: isLoading ? null : _makeDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9A5),
                foregroundColor: const Color(0xFF6B2C91),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B2C91)),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B2C91),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'S/',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D9A5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Donar con Yape',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// 💵 Montos sugeridos
  Widget _buildSuggestedAmounts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💵 Montos sugeridos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 15),
          
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: suggestedAmounts.map((amount) {
              final isSelected = selectedAmount == amount;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAmount = amount;
                  });
                  _showAmountSelectedToast(amount);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00D9A5) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00D9A5) : Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'S/ $amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF6B2C91) : const Color(0xFF6B2C91),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 10),
          
          Text(
            'Selecciona un monto o ingresa el que desees en Yape',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Instrucciones paso a paso
  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B2C91).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF6B2C91),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '¿Cómo donar?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B2C91),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildInstructionStep(
            number: '1',
            title: 'Abre tu app de Yape',
            description: 'Toca el botón "Abrir Yape" o escanea el QR',
            icon: Icons.phone_android,
          ),
          
          _buildInstructionStep(
            number: '2',
            title: 'Ingresa el monto',
            description: 'Elige un monto sugerido o el que desees',
            icon: Icons.attach_money,
          ),
          
          _buildInstructionStep(
            number: '3',
            title: 'Confirma tu donación',
            description: 'Revisa los datos y confirma el pago',
            icon: Icons.check_circle_outline,
          ),
          
          _buildInstructionStep(
            number: '4',
            title: '¡Listo!',
            description: 'Tu donación ayudará a salvar vidas',
            icon: Icons.favorite,
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// 📝 Paso de instrucción
  Widget _buildInstructionStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B2C91),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: const Color(0xFF6B2C91).withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
            ],
          ),
          
          const SizedBox(width: 15),
          
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: const Color(0xFF6B2C91)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B2C91),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 Sección de impacto
  Widget _buildImpactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pets, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Tu impacto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildImpactItem(
            amount: 'S/ 5',
            description: 'Alimentación para 1 mascota por 1 día',
            icon: Icons.restaurant,
          ),
          
          _buildImpactItem(
            amount: 'S/ 20',
            description: 'Vacunas y desparasitación',
            icon: Icons.medical_services,
          ),
          
          _buildImpactItem(
            amount: 'S/ 50',
            description: 'Esterilización de 1 mascota',
            icon: Icons.healing,
          ),
          
          _buildImpactItem(
            amount: 'S/ 100',
            description: 'Rescate y atención veterinaria completa',
            icon: Icons.favorite,
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// 📊 Item de impacto
  Widget _buildImpactItem({
    required String amount,
    required String description,
    required IconData icon,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).cardColor, size: 24),
          ),
          
          const SizedBox(width: 15),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D9A5),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💰 Realizar donación
  Future<void> _makeDonation() async {
    if (selectedAmount == null) {
      _showError('Por favor selecciona un monto');
      return;
    }

    setState(() => isLoading = true);

    try {
      Logger.info('Iniciando donación de S/ $selectedAmount', tag: 'DonationsScreen');

      // Crear la donación en el backend
      final donation = await _donationService.createDonation(
        amount: selectedAmount!.toDouble(),
        paymentMethod: 'yape',
        message: 'Donación desde PawFinder - ¡Ayudando a las mascotas!',
      );

      if (donation != null) {
        Logger.info('Donación creada exitosamente: ${donation.id}', tag: 'DonationsScreen');
        
        // Mostrar éxito
        _showSuccess('¡Donación registrada exitosamente!');
        
        // Abrir Yape
        await _openYapeApp();
        
        // Mostrar diálogo de confirmación
        _showConfirmationDialog(donation.id);
      } else {
        _showError('Error al registrar la donación. Intenta nuevamente.');
      }
    } catch (e) {
      Logger.error('Error al crear donación', tag: 'DonationsScreen', error: e);
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Mostrar diálogo de confirmación
  void _showConfirmationDialog(String donationId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9A5).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF00D9A5), size: 30),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '¡Donación Registrada!',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu donación ha sido registrada exitosamente.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B2C91).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Color(0xFF6B2C91), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Monto: S/ $selectedAmount',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B2C91),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.qr_code, color: Color(0xFF6B2C91), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ID: $donationId',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '¿Completaste el pago en Yape?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Si ya realizaste el pago, puedes confirmar tu donación ingresando el código de operación de Yape.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selectedAmount = null);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showTransactionIdDialog(donationId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D9A5),
              foregroundColor: const Color(0xFF6B2C91),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirmar Pago'),
          ),
        ],
      ),
    );
  }

  /// 🔢 Mostrar diálogo para ingresar código de transacción
  void _showTransactionIdDialog(String donationId) {
    final TextEditingController transactionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar Donación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el código de operación de Yape:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: transactionController,
              decoration: InputDecoration(
                labelText: 'Código de operación',
                hintText: 'Ej: YAPE-123456',
                prefixIcon: const Icon(Icons.confirmation_number),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selectedAmount = null);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final transactionId = transactionController.text.trim();
              if (transactionId.isEmpty) {
                _showError('Por favor ingresa el código de operación');
                return;
              }

              Navigator.pop(context);
              await _confirmDonation(donationId, transactionId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B2C91),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /// ✅ Confirmar donación con código de transacción
  Future<void> _confirmDonation(String donationId, String transactionId) async {
    setState(() => isLoading = true);

    try {
      Logger.info('Confirmando donación $donationId', tag: 'DonationsScreen');

      final success = await _donationService.confirmDonation(
        donationId,
        transactionId,
      );

      if (success) {
        _showSuccess('¡Donación confirmada! Gracias por tu apoyo 💚');
        setState(() => selectedAmount = null);
      } else {
        _showError('Error al confirmar la donación');
      }
    } catch (e) {
      Logger.error('Error al confirmar donación', tag: 'DonationsScreen', error: e);
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Mostrar mensaje de éxito
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF00D9A5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// ❌ Mostrar mensaje de error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 📋 Copiar al portapapeles
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: '📋 Número copiado: $text',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF00D9A5),
      textColor: const Color(0xFF6B2C91),
      fontSize: 16.0,
    );
  }

  /// 📱 Abrir app de Yape
  Future<void> _openYapeApp() async {
    try {
      // Intentar abrir Yape con deep link
      final yapeUrl = Uri.parse('yape://');
      
      if (await canLaunchUrl(yapeUrl)) {
        await launchUrl(yapeUrl, mode: LaunchMode.externalApplication);
      } else {
        // Si no está instalado, mostrar mensaje
        _showYapeNotInstalledDialog();
      }
    } catch (e) {
      _showYapeNotInstalledDialog();
    }
  }

  /// ⚠️ Diálogo de Yape no instalado
  void _showYapeNotInstalledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B2C91).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info_outline, color: Color(0xFF6B2C91)),
            ),
            const SizedBox(width: 12),
            const Text('Yape no instalado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para donar con Yape necesitas tener la app instalada.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 15),
            Text(
              'También puedes:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Escanear el QR desde otra app\n• Copiar el número: $yapeNumber\n• Descargar Yape desde Play Store',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(yapeNumber);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B2C91),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Copiar número'),
          ),
        ],
      ),
    );
  }

  /// 💬 Toast de monto seleccionado
  void _showAmountSelectedToast(int amount) {
    Fluttertoast.showToast(
      msg: '✨ Monto seleccionado: S/ $amount',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF00D9A5),
      textColor: const Color(0xFF6B2C91),
      fontSize: 16.0,
    );
  }
}
