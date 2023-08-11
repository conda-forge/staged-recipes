// Configure react-testing-library
// See https://create-react-app.dev/docs/running-tests/#option-2-react-testing-library
import '@testing-library/jest-dom/extend-expect';

// Configure enzyme
// See https://create-react-app.dev/docs/running-tests/#srcsetuptestsjs
import { configure } from 'enzyme';
import Adapter from '@wojtekmaj/enzyme-adapter-react-17';

// Require to create jest using Plotly.js library
window.URL.createObjectURL = jest.fn();

configure({ adapter: new Adapter() });
