import { NativeModules } from 'react-native';
console.log('NativeModules', NativeModules)
import { LINKING_ERROR } from '../../constants';

const NAME = 'NavigationModule';

type NavigationType = {

};

/// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;
const Module = isTurboModuleEnabled
  ? require('./specs/NativeNavigation').default
  : NativeModules[NAME];

const RCTNavigation = Module
  ? Module
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function useNavigation() {
  async function startNavigation() {
    return RCTNavigation
  }

  async function stopNavigation(resolve,reject) {
    // return await RCTNavigation.cancel(resolve,reject);
  }

  return { startNavigation, stopNavigation };
}
