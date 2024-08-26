import { Address, toNano } from '@ton/core';
import { SampleJetton } from '../wrappers/SampleJetton';
import { NetworkProvider } from '@ton/blueprint';
import { buildOnchainMetadata } from '../utils/jetton-helpers';

export async function run(provider: NetworkProvider) {
    // JettonA Deploy
    const jettonParamsA = {
        name: "Jetton A Token",
        description: "Jetton A Token",
        symbol: "JETTONATOKEN",
        image: "https://c0.klipartz.com/pngpicture/121/691/gratis-png-letra-del-alfabeto-ruso-буква.png",
    };

    // Create content Cell for JettonA deploy
    let contentA = buildOnchainMetadata(jettonParamsA);

    const sampleJettonA = provider.open(await SampleJetton.fromInit(provider.sender().address as Address, contentA, 1000000000000000000n));

    await sampleJettonA.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Mint',
            amount: 10000000000n,
            receiver: provider.sender().address as Address
        }
    );

    await provider.waitForDeploy(sampleJettonA.address);
    console.log('JettonA Address:', sampleJettonA.address)
    
    // JettonB Deploy
    const jettonParamsB = {
        name: "Jetton B Token",
        description: "Jetton B Token",
        symbol: "JETTONBTOKEN",
        image: "https://w7.pngwing.com/pngs/493/486/png-transparent-b-letter-red-alphabet-letters-letters-and-numbers-icon.png",
    };

    // Create content Cell for JettonB deploy
    let contentB = buildOnchainMetadata(jettonParamsB);

    const sampleJettonB = provider.open(await SampleJetton.fromInit(provider.sender().address as Address, contentB, 1000000000000000000n));

    await sampleJettonB.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Mint',
            amount: 2000000000n,
            receiver: provider.sender().address as Address
        }
    );

    await provider.waitForDeploy(sampleJettonB.address);
    console.log('JettonB Address:', sampleJettonB.address)
    // run methods on `sampleJetton`
}
