import cv2

print("Testing camera...")

cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)

if not cap.isOpened():
    print("❌ Camera could not be opened")
    exit()

print("✅ Camera opened successfully")

while True:
    ret, frame = cap.read()

    if not ret:
        print("❌ Failed to grab frame")
        break

    cv2.imshow("Camera Test", frame)

    key = cv2.waitKey(1)

    if key == 27:  # ESC key
        break

cap.release()
cv2.destroyAllWindows()

print("Camera test finished")