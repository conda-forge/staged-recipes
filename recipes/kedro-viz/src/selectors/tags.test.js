import { mockState } from '../utils/state.mock';
import { getTagData, getTagCount, getTagNodeCounts } from './tags';
import { toggleTagFilter } from '../actions/tags';
import reducer from '../reducers';

const getTagIDs = (state) => state.tag.ids;
const tagIDs = getTagIDs(mockState.spaceflights);
const tagData = getTagData(mockState.spaceflights);

describe('Selectors', () => {
  describe('getTagData', () => {
    it('retrieves the formatted list of tag filters', () => {
      expect(tagData).toEqual(
        expect.arrayContaining([
          expect.objectContaining({
            id: expect.any(String),
            name: expect.any(String),
            active: false,
            enabled: false,
          }),
        ])
      );
    });

    it('retrieves a list of tags sorted by ID name', () => {
      expect(tagData.map((d) => d.id)).toEqual(tagIDs.sort());
    });
  });

  describe('getTagCount', () => {
    const newMockState = reducer(
      mockState.spaceflights,
      toggleTagFilter(tagIDs[0], true)
    );

    it('retrieves the total and enabled number of tags', () => {
      expect(getTagCount(mockState.spaceflights)).toEqual(
        expect.objectContaining({
          enabled: 0,
          total: tagIDs.length,
        })
      );
    });

    it('retrieves the total and enabled number of tags when enabled count is updated', () => {
      expect(getTagCount(newMockState)).toEqual(
        expect.objectContaining({
          enabled: 1,
          total: tagIDs.length,
        })
      );
    });
  });

  describe('getTagNodeCounts', () => {
    it('gets the total number of nodes for each tag', () => {
      expect(getTagNodeCounts(mockState.spaceflights)).toEqual(
        expect.objectContaining({
          features: 5,
          preprocessing: 6,
          split: 7,
          train: 4,
        })
      );
    });
  });
});
