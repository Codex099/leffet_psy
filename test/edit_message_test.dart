import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/controllers/assistant_ia_controller.dart';
import 'package:leffet_psy/app/models/chat_session_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.loadFromString(
      envString: 'GEMINI_API_KEY=test_key',
    );
  });

  test('AssistantIaController editUserMessage updates text without resend', () async {
    final controller = AssistantIaController();
    
    final msg1 = ChatMessage(text: "Premier message", role: MessageRole.user);
    final msg2 = ChatMessage(text: "Réponse IA", role: MessageRole.assistant);
    controller.messages.addAll([msg1, msg2]);

    await controller.editUserMessage(0, "Message modifié", resend: false);

    expect(controller.messages[0].text, equals("Message modifié"));
    expect(controller.messages[0].role, equals(MessageRole.user));
    expect(controller.messages[1].text, equals("Réponse IA"));
  });

  test('AssistantIaController copyToInput copies message text to input field', () {
    final controller = AssistantIaController();
    controller.copyToInput("Texte copié dans la saisie");

    expect(controller.textController.text, equals("Texte copié dans la saisie"));
    expect(controller.inputText.value, equals("Texte copié dans la saisie"));
  });
}
