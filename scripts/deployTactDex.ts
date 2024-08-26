import { toNano, Address, address } from '@ton/core';
import { TactDex } from '../wrappers/TactDex';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const owner: Address = address("0QBGIUo7S6MuJzIca95_MeiNN_XCEaKOlWdXM492LDFVtvVB");
    const jettonAddressA: Address = address("EQD00phJNi53ymujfhmbg3mBenqFwM0k7IiwxRaRgWU7VKyB");
    const jettonAddressB: Address = address("EQDarjE_Fta2vkIROg9Sj2Dhgy0GnJ-5n9V1SQOmjHqvJTXk");
    const tactDex = provider.open(await TactDex.fromInit(owner, jettonAddressA, jettonAddressB));
    await tactDex.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(tactDex.address);

    // run methods on `tactDex`
}
