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

    if (showInput.value) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: _LoginWithCode(
          onCancel: () {
            showInput.value = false;
          },
        ),
      );
    } else {
      return ListTile(
        leading: Icon(Icons.tv),
        title: Text(AppLocalizations.of(context)!.connectTVAuth),
        onTap: () {
          showInput.value = true;
        },
      );
    }
  }
}

class _LoginWithCode extends HookWidget {
  final VoidCallback onCancel;

  const _LoginWithCode({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isLoading = useState(false);
    ValueNotifier<String> code = useState("");

    return Row(
      children: [
        Icon(Icons.tv),
        SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            enabled: !isLoading.value,
            autofocus: true,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]")),
            ],
            decoration: InputDecoration(border: InputBorder.none),
            onChanged: (value) => code.value = value,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) => SizedBox.shrink(),
          ),
        ),
        SizedBox(width: 8),
        if (isLoading.value) ...[
          SizedBox.square(dimension: 24, child: CircularProgressIndicator()),
          SizedBox(width: 8),
        ],
        if (!isLoading.value) ...[
          IconButton(
            onPressed: () async {
              if (code.value.length == 6) {
                isLoading.value = true;
                try {
                  await Auth().signInWithPairCode(code.value);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.connectTVInvalidCode,
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
                isLoading.value = false;
              }
            },
            icon: Icon(Icons.check),
          ),
          IconButton(onPressed: onCancel, icon: Icon(Icons.cancel_outlined)),
        ],
      ],
    );
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
        title: Text(
          AppLocalizations.of(context)!.connectTVValue(pairCode.value!),
        ),
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
