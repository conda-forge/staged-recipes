import React from 'react';
import { MetaDataCode } from './metadata-code';
import { setup } from '../../utils/state.mock';

describe('MetaDataCode', () => {
  const testCode = 'def test(): print "hello"';

  it('shows the value as highlighted code', () => {
    const wrapper = setup.mount(
      <MetaDataCode visible={true} value={testCode} />
    );

    // Jest can't query DOM rendered by highlight.js
    const highlighted = wrapper
      .find('.pipeline-metadata-code__code pre')
      .html();

    // Test a sample of expected highlighted code
    expect(highlighted.includes('<span class="hljs-title">test</span>')).toBe(
      true
    );
    expect(
      highlighted.includes('<span class="hljs-string">"hello"</span>')
    ).toBe(true);
  });

  it('adds sidebarVisible class when sidebarVisible prop is true', () => {
    const wrapper = setup.mount(
      <MetaDataCode sidebarVisible={true} visible={true} value={testCode} />
    );
    expect(
      wrapper.find('.pipeline-metadata-code--sidebarVisible').exists()
    ).toBe(true);
    expect(
      wrapper.find('.pipeline-metadata-code--no-sidebarVisible').exists()
    ).toBe(false);
  });

  it('removes sidebarVisible class when sidebarVisible prop is false', () => {
    const wrapper = setup.mount(
      <MetaDataCode sidebarVisible={false} visible={true} value={testCode} />
    );
    expect(
      wrapper.find('.pipeline-metadata-code--sidebarVisible').exists()
    ).toBe(false);
    expect(
      wrapper.find('.pipeline-metadata-code--no-sidebarVisible').exists()
    ).toBe(true);
  });
});
