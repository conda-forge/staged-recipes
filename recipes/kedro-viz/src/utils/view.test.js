/* eslint-disable id-length */

import React from 'react';
import { mount } from 'enzyme';

import {
  viewing,
  origin,
  isOrigin,
  isInvalidTransform,
  viewTransformToFit,
  setViewTransform,
  setViewTransformExact,
  getViewTransform,
  setViewExtents,
  getViewExtents,
  getViewport,
  setViewport,
} from './view';

describe('view', () => {
  const mockView = (width, height) => {
    const container = React.createRef();
    const wrapper = React.createRef();

    mount(
      <>
        <div ref={container}>
          <div ref={wrapper} />
        </div>
      </>
    );

    const view = viewing({
      container,
      wrapper,
      onViewChanged: jest.fn(),
      onViewEnd: jest.fn(),
    });

    // Elements have no dimensions in Jest so set viewport manually
    setViewport(view, {
      top: 0,
      left: 0,
      bottom: height,
      right: width,
    });

    return view;
  };

  describe('viewing', () => {
    it('returns an object with zoom function, container and wrapper refs', () => {
      const container = React.createRef();
      const wrapper = React.createRef();
      const view = viewing({
        container,
        wrapper,
        onViewChanged: jest.fn(),
        onViewEnd: jest.fn(),
      });
      expect(view.zoom).toBeInstanceOf(Function);
      expect(view.container).toBe(container);
      expect(view.wrapper).toBe(wrapper);
    });
  });

  describe('origin', () => {
    it('is equivalent to transform [0, 0, 1]', () => {
      expect(origin.x).toBe(0);
      expect(origin.y).toBe(0);
      expect(origin.k).toBe(1);
    });
  });

  describe('isOrigin', () => {
    it('returns true for any transform equivalent to [0, 0, 1] otherwise false', () => {
      expect(isOrigin({ x: 0, y: 0, k: 1 })).toBe(true);
      expect(isOrigin(origin)).toBe(true);

      expect(isOrigin({ x: 0, y: 0, k: 0 })).toBe(false);
      expect(isOrigin({ x: 1, y: 0, k: 0 })).toBe(false);
      expect(isOrigin({ x: 0, y: 1, k: 0 })).toBe(false);
      expect(isOrigin({ k: 1 })).toBe(false);
    });
  });

  describe('isInvalidTransform', () => {
    it('returns true if any component is infinite, `NaN` or `undefined` or `(0,0,0)` otherwise false', () => {
      expect(isInvalidTransform({})).toBe(true);

      expect(isInvalidTransform({ x: Infinity, y: 0, k: 0 })).toBe(true);
      expect(isInvalidTransform({ x: 0, y: Infinity, k: 0 })).toBe(true);
      expect(isInvalidTransform({ x: 0, y: 0, k: Infinity })).toBe(true);

      expect(isInvalidTransform({ x: NaN, y: 0, k: 0 })).toBe(true);
      expect(isInvalidTransform({ x: 0, y: NaN, k: 0 })).toBe(true);
      expect(isInvalidTransform({ x: 0, y: 0, k: NaN })).toBe(true);
      expect(isInvalidTransform({ x: 0, y: 0, k: 0 })).toBe(true);

      expect(isInvalidTransform({ x: undefined, y: 0, k: 0 })).toBe(true);
      expect(isInvalidTransform({ x: 0, y: undefined, k: 0 })).toBe(true);
      expect(isInvalidTransform({ x: 0, y: 0, k: undefined })).toBe(true);

      expect(isInvalidTransform({ x: -Infinity, y: undefined, k: NaN })).toBe(
        true
      );

      expect(isInvalidTransform({ x: 1, y: 1, k: 1 })).toBe(false);
      expect(isInvalidTransform({ x: -1, y: -1, k: -1 })).toBe(false);
    });
  });

  describe('getViewport, setViewport', () => {
    it('getViewport returns the initial viewport', () => {
      const view = mockView(100, 100);
      expect(getViewport(view)).toEqual({
        top: 0,
        left: 0,
        bottom: 100,
        right: 100,
      });
    });

    it('getViewport returns the updated viewport after setViewport', () => {
      const view = mockView(100, 200);
      const viewport = {
        top: 50,
        left: -50,
        bottom: 100,
        right: 150,
      };

      setViewport(view, viewport);
      expect(getViewport(view)).toEqual(viewport);
    });
  });

  describe('setViewTransform, getViewTransform, setViewTransformExact', () => {
    it('getViewTransform equivalent to origin for an untransformed view', () => {
      const view = mockView(0, 0);
      const v = getViewTransform(view);
      expect(v).toEqual(origin);
    });

    it('setViewTransform absolute: v = t', () => {
      const view = mockView(0, 0);

      const t = { x: 5, y: 10, k: 2 };
      setViewTransform(view, t, 0, false);

      const v = getViewTransform(view);
      expect(v).toEqual(t);
    });

    it('setViewTransform absolute only scale: vk = tk', () => {
      const view = mockView(0, 0);

      const t = { k: 2 };
      setViewTransform(view, t, 0, false);

      const v = getViewTransform(view);
      expect(v.x).toEqual(0);
      expect(v.y).toEqual(0);
      expect(v.k).toEqual(t.k);
    });

    it('setViewTransform absolute only translate: vxy = txy', () => {
      const view = mockView(0, 0);

      const t = { x: 5, y: 10 };
      setViewTransform(view, t, 0, false);

      const v = getViewTransform(view);
      expect(v.x).toEqual(t.x);
      expect(v.y).toEqual(t.y);
      expect(v.k).toEqual(1);
    });

    it('setViewTransform relative: v = t1 + t2', () => {
      const view = mockView(0, 0);

      const t1 = { x: 5, y: 10, k: 2 };
      setViewTransform(view, t1, 0, false);

      const t2 = { x: 5, y: 20, k: 0.5 };
      setViewTransform(view, t2, 0, true);

      const v = getViewTransform(view);
      expect(v.x).toEqual(t1.x + t2.x);
      expect(v.y).toEqual(t1.y + t2.y);
      expect(v.k).toEqual(t1.k + t2.k);
    });

    it('setViewTransform relative scale only: vk = t1k + t2k', () => {
      const view = mockView(0, 0);

      const t1 = { k: 2 };
      setViewTransform(view, t1, 0, false);

      const t2 = { k: 0.5 };
      setViewTransform(view, t2, 0, true);

      const v = getViewTransform(view);
      expect(v.x).toEqual(0);
      expect(v.y).toEqual(0);
      expect(v.k).toEqual(t1.k + t2.k);
    });

    it('setViewTransform relative translate only: vxy = t1xy + t2xy', () => {
      const view = mockView(0, 0);

      const t1 = { x: 5, y: 10 };
      setViewTransform(view, t1, 0, false);

      const t2 = { x: 5, y: 20 };
      setViewTransform(view, t2, 0, true);

      const v = getViewTransform(view);
      expect(v.x).toEqual(t1.x + t2.x);
      expect(v.y).toEqual(t1.y + t2.y);
      expect(v.k).toEqual(1);
    });

    it('setViewTransformExact: v = t', () => {
      const view = mockView(0, 0);

      const t = { x: 5, y: 10, k: 2 };
      setViewTransformExact(view, t);

      const v = getViewTransform(view);
      expect(v).toEqual(t);
    });

    it('setViewTransform respects extents', () => {
      const view = mockView(0, 0);

      const extents = {
        translate: {
          minX: -110,
          minY: -120,
          maxX: 120,
          maxY: 130,
        },
        scale: {
          minK: 1,
          maxK: 1.5,
        },
      };

      setViewExtents(view, extents);

      // Attempt going beyond max extents and max scale
      setViewTransform(
        view,
        { x: 500, y: 500, k: extents.scale.maxK * 2 },
        0,
        false
      );

      // Result should have constrained to max extents * max scale
      const v = getViewTransform(view);
      expect(v.x).toEqual(extents.translate.maxX * extents.scale.maxK);
      expect(v.y).toEqual(extents.translate.maxY * extents.scale.maxK);
      expect(v.k).toEqual(extents.scale.maxK);

      // Attempt going beyond min extents and min scale
      setViewTransform(
        view,
        { x: -500, y: -500, k: extents.scale.minK * 0.5 },
        0,
        false
      );

      // Result should have constrained to min extents * min scale
      const v2 = getViewTransform(view);
      expect(v2.x).toEqual(extents.translate.minX * extents.scale.minK);
      expect(v2.y).toEqual(extents.translate.minY * extents.scale.minK);
      expect(v2.k).toEqual(extents.scale.minK);
    });
  });

  describe('getViewExtents, setViewExtents', () => {
    it('getViewExtents returns initial infinite extents', () => {
      const view = mockView(100, 100);

      expect(getViewExtents(view)).toEqual({
        translate: {
          minX: -Infinity,
          maxX: Infinity,
          minY: -Infinity,
          maxY: Infinity,
        },
        scale: {
          minK: 0,
          maxK: Infinity,
        },
      });
    });

    it('setViewExtents applies given extents and getViewExtents returns same', () => {
      const view = mockView(100, 100);

      const extents = {
        translate: {
          minX: -1,
          maxX: 2,
          minY: -3,
          maxY: 4,
        },
        scale: {
          minK: 0.5,
          maxK: 0.6,
        },
      };

      setViewExtents(view, extents);
      expect(getViewExtents(view)).toEqual(extents);
    });
  });

  describe('viewTransformToFit', () => {
    it('returns expected transform when example must be scaled down to fit', () => {
      // Example where object dimensions larger than view dimensions
      const minScaleFocus = 0.8;
      const transform = viewTransformToFit({
        offset: { x: 10, y: 10 },
        focus: { x: 50, y: 50 },
        viewWidth: 200,
        viewHeight: 100,
        objectWidth: 150,
        objectHeight: 300,
        minScaleX: 0.4,
        minScaleFocus,
        focusOffset: 0.8,
      });

      // Resulting transform should clamp to minimum scale and center
      expect(transform.k).toEqual(minScaleFocus);

      // In this example offset may be fractional
      expect(transform.x).toEqual(-50);
      expect(transform.y).toBeCloseTo(6.666);
    });

    it('returns expected transform when example must be scaled up to fit', () => {
      // Example where object dimensions smaller than view dimensions
      const transform = viewTransformToFit({
        offset: { x: 10, y: 10 },
        focus: { x: 25, y: 25 },
        viewWidth: 200,
        viewHeight: 100,
        objectWidth: 50,
        objectHeight: 50,
        minScaleX: 0.4,
        minScaleFocus: 0.8,
        focusOffset: 0.8,
      });

      // Resulting transform should scale up and center
      expect(transform).toEqual({
        k: 2,
        x: -60,
        y: -10,
      });
    });

    it('returns expected transform when focus point is outside view so must offset to ensure visibility', () => {
      // Example where object dimensions larger than view dimensions
      // and focus point is set such that it will fall outside the view
      const minScaleFocus = 0.8;
      const transform = viewTransformToFit({
        offset: { x: 10, y: 10 },
        focus: { x: 500, y: 25 },
        viewWidth: 200,
        viewHeight: 100,
        objectWidth: 1000,
        objectHeight: 500,
        minScaleX: 0.4,
        minScaleFocus,
        focusOffset: 0.8,
      });

      // Resulting transform should clamp to minimum focus scale and center on focus point
      expect(transform).toEqual({
        k: minScaleFocus,
        x: 290,
        y: -4,
      });
    });

    it('returns expected transform when example is scaled to the minimum x scale', () => {
      // Example where object wider than view width
      const minScaleX = 0.4;
      const transform = viewTransformToFit({
        offset: { x: 10, y: 10 },
        viewWidth: 200,
        viewHeight: 100,
        objectWidth: 1000,
        objectHeight: 50,
        minScaleX,
        minScaleFocus: 0.8,
        focusOffset: 0.8,
        preventZoom: true,
      });

      // Resulting transform should clamp to minimum X scale and center
      expect(transform).toEqual({
        k: minScaleX,
        x: 90,
        y: -50,
      });
    });
  });
});
