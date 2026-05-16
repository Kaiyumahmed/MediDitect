# MediDitect 🌿

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![TensorFlow Lite](https://img.shields.io/badge/TensorFlow%20Lite-%23FF6F00.svg?style=for-the-badge&logo=TensorFlow&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

**MediDitect** is an offline, cross-platform mobile application that utilizes Deep Learning to accurately identify and classify medicinal plant leaves in real-time. 

Developed as the deployment prototype for the research study *"A Machine Learning Approach to Identify and Classify Medicinal Plant Leaves"* at Daffodil International University, this application bridges the gap between theoretical machine learning and practical, on-device smart healthcare utilities.

---

## 📖 About The Project

Traditional herbal medicine systems rely heavily on the accurate identification of specific plant species. However, many medicinal leaves look deceptively similar, making manual identification slow and heavily reliant on expert knowledge. Incorrect identification can lead to ineffective or potentially harmful medicinal usage. 

MediDitect acts as an expert botanical assistant directly in the user's pocket. Following a rigorous evaluation of five Convolutional Neural Network (CNN) architectures (Custom CNN, VGG16, ResNet50, DenseNet121, and MobileNetV2), **MobileNetV2** was selected as the deployment engine. By utilizing Depthwise Separable Convolutions, the model achieves a state-of-the-art diagnostic accuracy of **98.5%** while compressed into a highly efficient 14MB TensorFlow Lite file. 

The application performs inference entirely on-device, requiring no internet connection or cloud server processing. This makes it exceptionally reliable in remote or rural environments where traditional medicine is most prevalent.

---

## ✨ Key Features

* **Offline Edge AI:** Instant predictions powered by a fully embedded TFLite model. No internet connection or API calls required.
* **Smart Object Rejection:** Implements a custom green-pixel thresholding algorithm that actively scans RGB values to reject non-plant objects (e.g., human faces, background clutter) before running inference, mitigating Softmax overconfidence.
* **High Accuracy:** Trained on a proprietary, smartphone-captured dataset of 1,750 real-world images, achieving 98.5% validation accuracy.
* **Modern UI/UX:** Built natively with Flutter's Material 3 design system, featuring dynamic empty states, live camera integration, and photo gallery support.

---

## 🌿 Supported Plant Classes

The current model is trained to classify the following five highly prevalent medicinal species:
1. **Indian Pennywort** (Thankuni)
2. **Henna** (Mehedi)
3. **False Daisy** (Kalo Keshi)
4. **Basil** (Tulsi)
5. **Neem**

---

## 🛠 Tech Stack

**Mobile Application:**
* **Framework:** Flutter (Dart)
* **Design:** Material 3
* **Hardware Integration:** `image_picker` (Camera & Gallery)
* **Image Processing:** `image` package (Pixel normalization & matrix reshaping)

**Machine Learning:**
* **Training Pipeline:** Python, TensorFlow, Keras
* **Model Architecture:** MobileNetV2 (Transfer Learning)
* **On-Device Inference:** `tflite_flutter`

---

## 🚀 Getting Started

To run this project locally on your machine, follow these steps. **Note:** Testing the camera functionality requires compiling the app to a physical Android or iOS device.

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.11.5 or higher)
* Android Studio (for Android deployment) or Xcode (for iOS deployment)

### Installation

1. **Clone the repository**
   ```bash
   git clone [https://github.com/your-username/mediditect.git](https://github.com/your-username/mediditect.git)
   cd mediditect

```

2. **Install Flutter dependencies**
```bash
flutter pub get

```


3. **Run the application**
```bash
flutter run

```



### Building for Production

To generate a standalone Android installation file (APK):

```bash
flutter build apk --release

```

The compiled file will be located at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 👥 Authors & Academic Context

* **Kaiyum Ahmed** (ID: 222-15-6***)
* **S.M. Mojahedul Islam** (ID: 222-15-6***)

**Department of Computer Science and Engineering (CSE)**
*Daffodil International University*

```

```
