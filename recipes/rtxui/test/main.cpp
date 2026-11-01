// Copyright 2026 Arthur Sonzogni. All rights reserved.
// Use of this source code is governed by the MIT license that can be found in
// the LICENSE file.
//
// Must draw the built-in <button> and <checkbox>, which a library missing its
// built-in tags would draw as plain text.
#include <iostream>
#include <rtxui/rtxui.hpp>
#include <string>
#include <string_view>

class App : public rtxui::Component<App> {
 public:
  int count = 0;
  void Bump() { count++; }
  std::string_view view = R"html(
    <div>
      <button onclick="Bump">clicked {count}</button>
      <checkbox>check</checkbox>
    </div>
  )html";
  App() {
    Bind(count);
    Bind(Bump);
  }
};

int main() {
  rtxui::HeadlessScreen screen(rtxui::Ref<App>::New(), 30, 6);
  screen.Input("\t\r");
  const std::string text = screen.Text();
  std::cout << text << "\n";
  if (!text.contains("clicked 1") || !text.contains("☐ check")) {
    std::cerr << "unexpected output\n";
    return 1;
  }
  return 0;
}
