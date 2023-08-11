import {
  TOGGLE_MODULAR_PIPELINE_ACTIVE,
  TOGGLE_MODULAR_PIPELINES_EXPANDED,
  TOGGLE_SINGLE_MODULAR_PIPELINE_EXPANDED,
  TOGGLE_MODULAR_PIPELINE_DISABLED,
} from '../actions/modular-pipelines';

function modularPipelineReducer(modularPipelineState = {}, action) {
  const updateState = (newState) =>
    Object.assign({}, modularPipelineState, newState);

  /**
   * Batch update tags from an array of tag IDs
   * @param {String} key Tag action value prop
   */
  const batchChanges = (key) =>
    action.modularPipelineIDs.reduce((result, modularPipelineID) => {
      result[modularPipelineID] = action[key];
      return result;
    }, {});

  switch (action.type) {
    case TOGGLE_MODULAR_PIPELINE_ACTIVE: {
      return updateState({
        active: Object.assign(
          {},
          modularPipelineState.active,
          batchChanges('active')
        ),
      });
    }

    case TOGGLE_MODULAR_PIPELINE_DISABLED: {
      return updateState({
        disabled: Object.assign(
          {},
          modularPipelineState.disabled,
          batchChanges('disabled')
        ),
      });
    }

    case TOGGLE_SINGLE_MODULAR_PIPELINE_EXPANDED: {
      const newVisibleState = { ...modularPipelineState.visible };

      newVisibleState[action.modularPipelineID] = false;
      modularPipelineState.tree[action.modularPipelineID].children.forEach(
        (child) => (newVisibleState[child.id] = true)
      );

      return updateState({
        expanded: [...modularPipelineState.expanded, action.modularPipelineID],
        visible: newVisibleState,
      });
    }

    // The expanded IDs for tree nodes directly emitted from modular pipelines
    // are not directly usable for our purpose. For example, for a tree a -> b -> c,
    // when a is collapsed, [b,c] are passed to the action payload as expanded.
    // What we care about, however, is not what is currently "expanded", but actually
    // what is currently "visible" on the tree.
    // Therefore there are 2 states here: expanded and visible.
    // We use expanded state and the action's payload to work out what's visible:
    // - When a modular pipeline is collapsed, we have to mark all of its children
    // as invisible recursively.
    // - When a modular pipeline is expanded, we have to mark all of its children
    // as visible, but not recursively.
    case TOGGLE_MODULAR_PIPELINES_EXPANDED: {
      const newVisibleState = { ...modularPipelineState.visible };
      const isExpanding =
        action.expandedIDs.length > modularPipelineState.expanded.length;
      let expandedIDs = action.expandedIDs;

      if (isExpanding && modularPipelineState.ids.length > 0) {
        const expandedModularPipelines = expandedIDs.filter(
          (expandedID) => !modularPipelineState.expanded.includes(expandedID)
        );
        expandedModularPipelines.forEach((expandedModularPipeline) => {
          newVisibleState[expandedModularPipeline] = false;
          modularPipelineState.tree[expandedModularPipeline].children.forEach(
            (child) => (newVisibleState[child.id] = true)
          );
        });
      } else {
        const collapsedModularPipelines = modularPipelineState.expanded.filter(
          (expandedID) => !expandedIDs.includes(expandedID)
        );

        // recursively set all children of a node in the tree as invisible
        const setChildrenInvisible = (node) => {
          modularPipelineState.tree[node].children.forEach((child) => {
            newVisibleState[child.id] = false;
            if (child.type === 'modularPipeline') {
              setChildrenInvisible(child.id);
            }
          });
        };

        collapsedModularPipelines.forEach((collapsedModularPipeline) => {
          newVisibleState[collapsedModularPipeline] = true;
          setChildrenInvisible(collapsedModularPipeline);
          expandedIDs = expandedIDs.filter(
            (id) => !id.startsWith(collapsedModularPipeline)
          );
        });
      }

      return updateState({
        expanded: expandedIDs,
        visible: newVisibleState,
      });
    }

    default:
      return modularPipelineState;
  }
}

export default modularPipelineReducer;
