import { createElement } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import CountdownTimer from "c/countdownTimer";

describe("c-countdown-timer", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("displays the countdown timer", () => {
    
  });
});
