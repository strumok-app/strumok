import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/auth/auth.dart';

class ConnectTVWithCode extends StatefulWidget {
  const ConnectTVWithCode({super.key});

  @override
  State<ConnectTVWithCode> createState() => _ConnectTVWithCodeState();
}

class _ConnectTVWithCodeState extends State<ConnectTVWithCode> {
  bool showInput = false;
  final inputFocusNode = FocusNode();

  @override
  void dispose() {
    inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showInput) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
        child: _LoginWithCode(
          onCancel: () {
            setState(() {
              showInput = false;
            });
          },
          focusNode: inputFocusNode,
        ),
      );
    } else {
      return ListTile(
        leading: Icon(Icons.tv),
        title: Text(AppLocalizations.of(context)!.connectTVAuth),
        onTap: () {
          setState(() {
            showInput = true;
          });
          inputFocusNode.requestFocus();
        },
      );
    }
  }
}

class _LoginWithCode extends StatefulWidget {
  final VoidCallback onCancel;
  final FocusNode? focusNode;

  const _LoginWithCode({required this.onCancel, this.focusNode});

  @override
  State<_LoginWithCode> createState() => _LoginWithCodeState();
}

class _LoginWithCodeState extends State<_LoginWithCode> {
  bool isLoading = false;
  final codeEditController = TextEditingController();
  final acceptFocusNode = FocusNode();

  @override
  void dispose() {
    acceptFocusNode.dispose();
    codeEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.tv),
        SizedBox(width: 8),
        Expanded(
          child: BackButtonListener(
            onBackButtonPressed: () async {
              acceptFocusNode.requestFocus();
              return true;
            },
            child: TextField(
              controller: codeEditController,
              enabled: !isLoading,
              focusNode: widget.focusNode,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]")),
              ],
              decoration: InputDecoration(border: InputBorder.none),
              onSubmitted: (value) => _handleLoggin(context),
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) => SizedBox.shrink(),
            ),
          ),
        ),
        SizedBox(width: 8),
        if (isLoading) ...[
          SizedBox.square(dimension: 24, child: CircularProgressIndicator()),
          SizedBox(width: 8),
        ],
        if (!isLoading) ...[
          IconButton(
            focusNode: acceptFocusNode,
            onPressed: () => _handleLoggin(context),
            icon: Icon(Icons.check),
          ),
          IconButton(
            onPressed: widget.onCancel,
            icon: Icon(Icons.cancel_outlined),
          ),
        ],
      ],
    );
  }

  void _handleLoggin(BuildContext context) async {
    final code = codeEditController.text;
    if (code.length == 6) {
      setState(() {
        isLoading = true;
      });
      try {
        await Auth().signInWithPairCode(code.toUpperCase());
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.connectTVInvalidCode),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

class ConnectTVCode extends StatefulWidget {
  const ConnectTVCode({super.key});

  @override
  State<ConnectTVCode> createState() => _ConnectTVCodeState();
}

class _ConnectTVCodeState extends State<ConnectTVCode> {
  String? pairCode;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (pairCode == null) {
      return ListTile(
        leading: Icon(Icons.tv),
        title: Text(AppLocalizations.of(context)!.connectTV),
        onTap: () async {
          if (!isLoading) {
            setState(() {
              isLoading = true;
            });

            final code = await Auth().getPairCode();

            if (mounted) {
              setState(() {
                pairCode = code;
                isLoading = false;
              });
            }
          }
        },
        trailing: isLoading
            ? SizedBox.square(dimension: 24, child: CircularProgressIndicator())
            : null,
      );
    } else {
      return ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        leading: Icon(Icons.tv),
        title: Text(pairCode!),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              pairCode = null;
            });
          },
          icon: Icon(Icons.delete),
        ),
      );
    }
  }
}
