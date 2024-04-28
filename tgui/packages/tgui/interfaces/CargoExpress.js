import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { CargoCatalog } from './Cargo';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const CargoExpress = (props, context) => {
  const { act, data } = useBackend(context);
  const { locked } = data;
  return (
    <Window
      width={600}
      height={700}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox />
        {!locked && (
          <CargoExpressContent />
        )}
      </Window.Content>
    </Window>
  );
};

const CargoExpressContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { uiCurrency = '' } = data;
  return (
    <>
      <Section
        title={data.uiTitle}
        buttons={(
          <Box inline bold>
            <AnimatedNumber
              value={Math.round(data.points)} />
            {uiCurrency}
          </Box>
        )}>
        <LabeledList>
          {!!data.canUseWithoutBeacon
          && (
            <LabeledList.Item label="Landing Location">
              <Button
                content="Cargo Bay"
                selected={!data.usingBeacon}
                onClick={() => act('LZCargo')} />

              <Button
                selected={data.usingBeacon}
                disabled={!data.hasBeacon}
                onClick={() => act('LZBeacon')}>
                {data.beaconzone} ({data.beaconName})
              </Button>
              <Button
                content={data.printMsg}
                disabled={!data.canBuyBeacon}
                onClick={() => act('printBeacon')} />
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Notice">
            {data.message}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <CargoCatalog express />
    </>
  );
};
