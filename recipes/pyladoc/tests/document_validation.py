from typing import Generator, Any
from lxml import etree
from lxml.etree import _Element as EElement  # type: ignore
import requests
import pyladoc


def add_line_numbers(multiline_string: str) -> str:
    lines = multiline_string.splitlines()
    numbered_lines = [f"{i + 1}: {line}" for i, line in enumerate(lines)]
    return "\n".join(numbered_lines)


def validate_html_with_w3c(html_string: str) -> dict[str, Any]:
    validator_url = "https://validator.w3.org/nu/"

    # Parameters for the POST request
    headers = {
        "Content-Type": "text/html; charset=utf-8",
        "User-Agent": "Python HTML Validator"}

    try:
        response = requests.post(validator_url, headers=headers, data=html_string, params={"out": "json"})

        if response.status_code == 200:
            return response.json()
        else:
            return {
                "error": f"Failed to validate HTML. Status code: {response.status_code}",
                "details": response.text
            }

    except requests.RequestException as e:
        return {"error": f"An error occurred while connecting to the W3C Validator: {str(e)}"}


def validate_html(html_string: str, validate_online: bool = False, check_for: list['str'] = ['table', 'svg', 'div']):
    root = etree.fromstring(html_string, parser=etree.HTMLParser(recover=True))

    def recursive_search(element: EElement) -> Generator[str, None, None]:
        if isinstance(element.tag, str):
            yield element.tag

        for child in element:
            yield from recursive_search(child)

    tags = set(recursive_search(root))

    for tag_type in check_for:
        assert tag_type in tags, f"Tag {tag_type} not found in the html code"

    if validate_online:
        test_page = pyladoc.inject_to_template(html_string, internal_template='templates/test_template.html')
        validation_result = validate_html_with_w3c(test_page)
        assert 'messages' in validation_result, 'Validate request failed'
        if validation_result['messages']:
            print(add_line_numbers(test_page))
        for verr in validation_result['messages']:
            print(f"- {verr['type']}: {verr['message']} (line: {verr['lastLine']})")

        assert len(validation_result['messages']) == 0, f'{len(validation_result["messages"])} validation error, first error: {validation_result["messages"][0]["message"]}'
