#include <iostream>
#include <vector>
#include <queue>
#include <chrono>
#include <map>
#include <bitset>
#include <cmath>

using namespace std;

class Node {
public:
int freq;
char symbol;
Node* left;
Node* right;
char huff;

Node(int freq, char symbol, Node* left = nullptr, Node* right = nullptr)
: freq(freq), symbol(symbol), left(left), right(right), huff(0) {}

bool operator<(const Node& other) const {
return freq > other.freq;

}
};

void printNodes(const Node* node, string val = "") {
if (node->left) {
printNodes(node->left, val + '0');
}
if (node->right) {
printNodes(node->right, val + '1');
}
if (!node->left && !node->right) {
cout << node->symbol << " -> " << val << endl;
}
}

void calculateHuffmanCodes(const Node* node, const string& code, map<char,
string>& huffmanCodes) {
if (node) {
if (!node->left && !node->right) {
huffmanCodes[node->symbol] = code;
}
calculateHuffmanCodes(node->left, code + "0", huffmanCodes);
calculateHuffmanCodes(node->right, code + "1", huffmanCodes);
}
}

int main() {
vector<char> chars = {'a', 'b', 'c', 'd', 'e', 'f'};

vector<int> freq = {5, 9, 12, 13, 16, 45};

priority_queue<Node> nodes;

for (size_t i = 0; i < chars.size(); ++i) {
nodes.push(Node(freq[i], chars[i]));
}

auto start_time = chrono::high_resolution_clock::now();

while (nodes.size() > 1) {
Node* left = new Node(nodes.top());
nodes.pop();
Node* right = new Node(nodes.top());
nodes.pop();

left->huff = '0';
right->huff = '1';

Node* newNode = new Node(left->freq + right->freq, left->symbol +
right->symbol, left, right);
nodes.push(*newNode);
}

auto end_time = chrono::high_resolution_clock::now();
auto duration = chrono::duration_cast<chrono::microseconds>(end_time -
start_time);

cout << "Huffman Tree Construction Elapsed Time: " << duration.count() <<
" microseconds" << endl;

map<char, string> huffmanCodes;
calculateHuffmanCodes(&nodes.top(), "", huffmanCodes);

// Calculate space used for the Huffman codes
double spaceUsed = 0;
for (const auto& kv : huffmanCodes) {
spaceUsed += kv.first * kv.second.length();
}
spaceUsed = ceil(spaceUsed / 8); // Convert bits to bytes

cout << "Estimated Space Used for Huffman Codes: " << spaceUsed << "bytes" << endl;

return 0;
}