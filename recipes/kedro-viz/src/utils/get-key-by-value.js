export const getKeyByValue = (object, value) => {
  return Object.keys(object).find((key) => object[key] === value);
};
