---
title: Some Notes on Testing Promises in React Components
tags:
  - react
  - programming
---

Javascript promises broke my brain the first time I encountered them. I've healed a little, but I sometimes get hung up on them in testing. The other day I was writing tests for a component with promise-based blocking behavior: the component allowed users to attach a text file that would be read and parsed by a separate utility function so that the data could be used to automatically populate some form fields. The utility function returned the data as a promise, and then the component sent the data to its parent via a callback. I wanted to test that the callback was being invoked correctly, and it proved painful.

This is a pattern I've seen a couple times: the component is responsible for receiving data at some unknown point in the future and then alerting its parent via a callback.[^1]

I made some sample code to demonstrate the solution I settled on. You can find it [here](https://github.com/dcorrigan/dfcorrigan). My code uses an API call as an example of promise-based blocking behavior.

For starters, here is the component:

~~~ jsx
import React from 'react'
import Api from './Api';

export default class RecipeSearch extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      searchTerm: null
    }
  }

  updateSearchTerm = (e) => {
    e.preventDefault();
    this.setState({searchTerm: e.target.value});
  }

  submit = () => {
    Api.get(
      'http://api.veryawesomerecipes.com/search',
      {query: this.state.searchTerm}
    ).then(json => {
      this.props.updateParent(json);
    })
  }

  render() {
    return (<form>
      <label htmlFor="search">Search for a recipe!</label>
      <input
        type="text"
        name="search"
        onChange={this.updateSearchTerm}
      />
      <input
        type="submit"
        value="Submit"
        onClick={this.submit}
      />
    </form>);
  }
}
~~~

It renders a simple form. It tracks user input with its state, and it sends the user search term to an API when the user clicks "Submit." The component will hopefully get a JSON response, and the component then gives that data to its parent via a callback. I'm not including the Api class here, but it's in the linked repo. For the purposes of discussion, just know that it returns a promise with the parsed JSON data from the response.

What if we want to test that the callback is fired in the above scenario? A straightforward attempt might look like this:[^2]

~~~ jsx

describe('RecipeSearch', () => {
  const defaultResponse = [{
    url: 'http://awesomerecipes.com/swedish-meatballs',
    name: 'Totally Awesome Swedish Meatballs'
  }];

  // use nock to mock the API response
  beforeEach(() => {
    nock('http://api.awesomerecipes.com')
      .get('/search')
      .reply(200, defaultResponse);
  });

  it('should return a list of recipes when the user searches', () => {
    let fetchedData;
    const updateMePlease = (data) => {
      fetchedData = data;
    }

    const component = mount(
      <RecipeSearch
        updateParent={updateMePlease}
      />
    );

    component.find('input[name="search"]')
      .simulate('change', {target: {value: 'swedish meatballs'}});
    component.find('input[type="submit"]').simulate('click');

    expect(fetchedData).to.deep.eq(defaultResponse);
  });
}
~~~

We have some sample data (`defaultResponse`), we mock the web request using nock in the `beforeEach` hook, and then we construct a callback function that populates a variable, `fetchedData`. `fetchedData` is declared in the test's scope. When our callback is invoked, `fetchedData` should be assigned the data we're expecting.

This test fails. The test has no way to wait for the API call inside the component's `submit` method to resolve, and so it makes the assertion about the content of `fetchedData` before our callback is invoked. There are two important ideas we need to implement to make the test work.

## Return a Promise in Mocha Tests of Promise-based Code

Mocha allows you to return a promise from a [test](https://mochajs.org/#working-with-promises). It even allows you to chain assertions on promise-based functions with an `eventually` method, but that's not helpful in our case because we're not calling the `submit` function of the component directly in our test.[^3]

Wrapping the internals of our test in a promise like this

~~~ jsx
  it('should return a list of recipes when the user searches', () => {
    return new Promise((resolve, reject) => {
      // test code goes here...
      resolve();
    })
  });
~~~

makes me feel like I accomplished something, but the test still fails. We need the test to _wait_ for the callback to execute. We can do that by letting the callback resolve our new promise.

## Let a Callback Prop Resolve the Test Promise

The `updateMePlease` function we pass to the component as its `updateParent` prop can resolve our promise. Once that's done, we _know_ the callback has been executed and we can check the content of our `fetchedData`.

~~~ jsx
  it('should return a list of recipes when the user searches', () => {
    let component;
    let fetchedData;

    return new Promise((resolve, reject) => {
      const updateMePlease = (data) => {
        fetchedData = data;
        // this is the important bit: let the callback function in the
        // component resolve this promise
        resolve(true);
      }

      component = mount(
        <RecipeSearch
          updateParent={updateMePlease}
        />
      );

      component.find('input[name="search"]')
        .simulate('change', {target: {value: 'swedish meatballs'}});
      component.find('input[type="submit"]').simulate('click');
    }).then(bool => {
      expect(fetchedData).to.deep.eq(defaultResponse);
    });
  });
~~~

The other thing to pay attention to here is variable scope. `component` and `fetchedData` both need to be declared with sufficient scope that both the initial promise and the then method have access to them.

This really just amounts to message passing. The test needs to know when the callback has been invoked so that it can check the data, so we give the callback a means to tell the test when it's finished. And voilà, a passing test.

[^1]: If you're using Flux architecture this might never come up because data-fetching activities are handled in the action layer. I sometimes have use for simple components with one or API calls, and its not worth it to me to introduce the added complexity of Flux.
[^2]: This post assume you have some familiarity with testing React components. For reference, the test uses [mocha](https://mochajs.org/), [chai](http://chaijs.com/), [enzyme](https://github.com/airbnb/enzyme), and [nock](https://github.com/node-nock/nock).
[^3]: We could, thanks to enzyme, using `component.instance().submit()`. This would be a more granular unit test. Some might argue this is a better approach, but I like that our current test emulates user behavior and is ignorant of the implementation details of the component.
