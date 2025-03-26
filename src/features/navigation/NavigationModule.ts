import { NativeModules } from 'react-native';
import { LINKING_ERROR } from '../../constants';

const NAME = 'NavigationModule';

type NavigationType = {

};

/// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;
const Module = isTurboModuleEnabled
  ? require('./specs/NavigationModule').default
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
  async function startNavigation(
    routeJson, isSimulate, resolve,reject
  ) {
    return await RCTNavigation.startNavigation(  routeJson, isSimulate, resolve,reject);
  }

  async function stopNavigation(resolve,reject) {
    return await RCTNavigation.cancel(resolve,reject);
  }

  return { startNavigation, stopNavigation };
}
