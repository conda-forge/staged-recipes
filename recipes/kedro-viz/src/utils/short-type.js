import { shortTypeMapping } from '../config';

const getShortType = (longTypeName, fallback) =>
  shortTypeMapping[longTypeName] || fallback;

export default getShortType;
