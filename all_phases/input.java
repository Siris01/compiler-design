class Main {
    public static void main() {
        int a = 1 + 2;
        int b = a + 4;
        int c  = a + b + a + b;

        int d = c * 4; // Dead code
    }
}