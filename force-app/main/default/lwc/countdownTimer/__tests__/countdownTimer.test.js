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
    const element = createElement("c-countdown-timer", {
      is: CountdownTimer,
    });
    document.body.appendChild(element);

    // Emit mock data
    const mockData = {
        'fields': {
          'Scoring_Start__c': {
            'value': new Date(Date.now() + 1000 * 60 * 60 * 24).toISOString(),
          },
          'Scoring_End__c': {
            'value': new Date(Date.now() + 1000 * 60 * 60 * 48).toISOString(),
          }
        }
      };
    getRecord.emit(mockData);
    jest.advanceTimersByTime(1000);
    // Wait for any asynchronous DOM updates
    return Promise.resolve().then(() => {
    //   expect(element.timeRemaining).toBe("299d 23h 59m 59s");
    });
  });
});
