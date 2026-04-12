import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.title,
    this.height,
    required this.hinttext,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  final String hinttext;
  final String title;
  final double? height;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF7A7A7A),
            fontSize: 18,
            fontFamily: 'regular',
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: TextFormField(
            obscureText: _isObscured,
            decoration: InputDecoration(
              constraints: BoxConstraints(minHeight: widget.height ?? 56),
              hintText: widget.hinttext,
              hintStyle: TextStyle(
                color: const Color(0xFF8B8B8B),
                fontSize: 12,
                fontFamily: 'regular',
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : Icon(widget.prefixIcon, size: 16, color: const Color(0xFF4A4A4A)),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                      icon: Icon(
                        _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF4A4A4A),
                      ),
                    )
                  : widget.suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class FillTextField extends StatelessWidget {
  const FillTextField({super.key, required this.hint});
  final String hint;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFB1B1B1),
          fontSize: 16,
          fontFamily: 'regular',
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFF4F4F4),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(14),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      ),
    );
  }
}
