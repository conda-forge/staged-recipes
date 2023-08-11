import React from 'react';
import { mount } from 'enzyme';
import PreviewTable from './preview-table';

const mockData = {
  columns: ['id', 'company_rating', 'company_location'],
  index: [0, 1, 2],
  data: [
    [1, '90%', 'London'],
    [2, '80%', 'Paris'],
    [3, '40%', 'Milan'],
  ],
};

describe('Preview Table', () => {
  it('renders without crashing', () => {
    const wrapper = mount(<PreviewTable data={mockData} />);

    expect(wrapper.find('.preview-table').length).toBe(1);
  });

  it('it should render the correct amount of header and rows', () => {
    const wrapper = mount(<PreviewTable data={mockData} />);

    expect(wrapper.find('.preview-table__header').length).toBe(
      mockData.columns.length
    );
    expect(wrapper.find('.preview-table__row').length).toBe(
      mockData.index.length
    );
  });
});
