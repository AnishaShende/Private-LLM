# Anisha's AI Assistant

An innovative Flutter application that offers a sophisticated AI assistant interface, seamlessly integrating multiple language models such as Gemma, Llama, and Mistral. This highly personalized assistant is meticulously trained on my data, delivering accurate and insightful responses to queries about my work and profile.

### **Key Technologies**
- **Flutter**: Frontend development.
- **ChromaDB**: Vector database.
- **FastAPI**: API endpoint creation.
- **Railway.com**: Backend deployment.
- **Docker**: Containerization for deployment.
- **GitHub Pages**: Frontend hosting.
- **Groq**: Optimized inference for large language models.

---

## **Screenshots**

![Screenshot (473)](https://github.com/user-attachments/assets/55c049bf-1875-4134-bc59-7ba7fc1dc36c)
![Screenshot (474)](https://github.com/user-attachments/assets/f75711ef-4962-4876-b151-de0e9f215885)


---

## **Features**

- Cross-platform compatibility (Android, Windows, Web).
- Chat interface with three AI models.
- File handling capabilities.
- Google Sheets integration for feedback collection.
- Markdown rendering support.
- Max API calls limit.

---

## **Environment Variables**

To run this project, you will need to configure the following environment variables in a `.env` file. Refer to `.env.example` for more details:

- `GEMMA_API_KEY`
- `LLAMA_API_KEY`
- `MISTRAL_API_KEY`
- `FEEDBACK_WEB_URL`
- `SHEET_ID`

---

## **Run Locally**

Clone the repository:

```bash
  git clone https://github.com/AnishaShende/Private-LLM
```

Navigate to the project directory:

```bash
  cd private_llm
```

Create a `.env` file based on `.env.example` with your API keys:

```env
GEMMA_API_KEY=your_gemma_api_key
LLAMA_API_KEY=your_llama_api_key
MISTRAL_API_KEY=your_mistral_api_key
FEEDBACK_WEB_URL=your_feedback_url
SHEET_ID=your_google_sheet_id
```

Install dependencies and run the application:

```bash
  flutter pub get
  flutter run
```

---

## **Deployment**

### **Building for Different Platforms**

**Desktop (Windows/macOS/Linux):**
```bash
flutter build windows
flutter build macos
flutter build linux
```

**Mobile:**
```bash
flutter build ios
flutter build apk
```

**Web:**
```bash
flutter build web
```

Docker image for the API endpoint is available at: [Docker Hub](https://hub.docker.com/repository/docker/anishashende/chroma-rag/general)

---

## **Dependencies**

- `flutter_markdown`: ^0.7.5 - Markdown rendering.
- `sidebarx`: ^0.17.1 - Sidebar navigation.
- `typewritertext`: ^3.0.9 - Typewriter text effects.
- `flutter_dotenv`: ^5.2.1 - Environment variable management.
- `groq_sdk`: ^1.0.2 - AI model integration.
- `shared_preferences`: ^2.3.4 - Local storage.
- `gsheets`: ^0.5.0 - Google Sheets integration.
- `http`: ^1.2.2 - HTTP requests.
- `url_launcher`: ^6.2.5 - URL launching.
- `window_manager`: ^0.3.8 - Window management.
- `open_file`: ^3.5.10 - File handling.

---

## **Installation**

Install the application using the installers available in the `installers` folder. For desktop platforms, follow the setup wizard to complete the installation.
The website has been successfully deployed and is accessible at [this link](https://white-coast-07f031310.4.azurestaticapps.net/) .

---

## **Demo**

[Insert gif or link to demo]

---

## **Feedback**

For feedback, feel free to reach out to me at: [anishaashende@gmail.com](mailto:anishaashende@gmail.com)

---

## **Author**

- [@AnishaShende](https://github.com/AnishaShende)

