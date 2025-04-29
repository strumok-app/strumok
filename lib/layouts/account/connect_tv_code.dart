import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/auth/auth.dart';

class ConnectTVWithCode extends HookWidget {
  const ConnectTVWithCode({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> showInput = useState(false);
    final inputFocusNode = useFocusNode();

    if (showInput.value) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
        child: _LoginWithCode(
          onCancel: () {
            showInput.value = false;
          },
          focusNode: inputFocusNode,
        ),
      );
    } else {
      return ListTile(
        leading: Icon(Icons.tv),
        title: Text(AppLocalizations.of(context)!.connectTVAuth),
        onTap: () {
          showInput.value = true;
          inputFocusNode.requestFocus();
        },
      );
    }
  }
}

class _LoginWithCode extends HookWidget {
  final VoidCallback onCancel;
  final FocusNode? focusNode;

  const _LoginWithCode({required this.onCancel, this.focusNode});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isLoading = useState(false);
    ValueNotifier<String> code = useState("");
    final acceptFocusNode = useFocusNode();

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
              enabled: !isLoading.value,
              focusNode: focusNode,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]")),
              ],
              decoration: InputDecoration(border: InputBorder.none),
              onChanged: (value) => code.value = value,
              onSubmitted: (value) => _handleLoggin(value, isLoading, context),
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
        if (isLoading.value) ...[
          SizedBox.square(dimension: 24, child: CircularProgressIndicator()),
          SizedBox(width: 8),
        ],
        if (!isLoading.value) ...[
          IconButton(
            focusNode: acceptFocusNode,
            onPressed: () => _handleLoggin(code.value, isLoading, context),
            icon: Icon(Icons.check),
          ),
          IconButton(onPressed: onCancel, icon: Icon(Icons.cancel_outlined)),
        ],
      ],
    );
  }

  void _handleLoggin(
    String code,
    ValueNotifier<bool> isLoading,
    BuildContext context,
  ) async {
    if (code.length == 6) {
      isLoading.value = true;
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
      isLoading.value = false;
    }
  }
}

class ConnectTVCode extends HookWidget {
  const ConnectTVCode({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String?> pairCode = useState(null);
    ValueNotifier<bool> isLoading = useState(false);

    if (pairCode.value == null) {
      return ListTile(
        leading: Icon(Icons.tv),
        title: Text(AppLocalizations.of(context)!.connectTV),
        onTap: () async {
          if (!isLoading.value) {
            isLoading.value = true;
            pairCode.value = await Auth().getPairCode();
            isLoading.value = false;
          }
        },
        trailing:
            isLoading.value
                ? SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(),
                )
                : null,
      );
    } else {
      return ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        leading: Icon(Icons.tv),
        title: Text(pairCode.value!),
        trailing: IconButton(
          onPressed: () {
            pairCode.value = null;
          },
          icon: Icon(Icons.delete),
        ),
      );
    }
  }
}
