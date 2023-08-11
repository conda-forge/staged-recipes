export const removeChildFromObject = (originalObj, itemsToRemove) => {
  let updatedObj = { ...originalObj };
  itemsToRemove.map((each) => {
    const { [each]: unused, ...rest } = updatedObj;

    return (updatedObj = { ...rest });
  });

  return updatedObj;
};

export const removeElementsFromObjectValues = (obj, itemsToRemove) => {
  let updatedObj = {};

  for (const [key, value] of Object.entries(obj)) {
    let newVal = [...value];
    newVal = newVal.filter(function (_, index) {
      return itemsToRemove.indexOf(index) === -1;
    });

    updatedObj[key] = newVal;
  }

  return updatedObj;
};
