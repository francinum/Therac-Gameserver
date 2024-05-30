import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState } from '../backend';
import {
  Button,
  Flex,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

export const TemplateConsole = (props) => {
  return (
    <Window width={550} height={500}>
      <Window.Content scrollable>
        <RecipeContent />
      </Window.Content>
    </Window>
  );
};

export const RecipeContent = (props) => {
  const { act, data } = useBackend();
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Write To Disk">
          <RecipeLoader />
          {data.disk_error && <NoticeBox>{data.disk_error}</NoticeBox>}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <RecipeCatalog />
      </Stack.Item>
    </Stack>
  );
};

export const RecipeLoader = (props) => {
  const { act, data } = useBackend();
  const { recipe_index, disk_loaded } = data;

  const [stagedRecipeName, setStagedRecipeName] = useSharedState(
    'staged_recipe_name',
    null,
  );

  let stagedRecipe = findRecipeByName(stagedRecipeName, recipe_index);

  if (!disk_loaded) {
    return <NoticeBox>No disk loaded</NoticeBox>;
  }

  if (!stagedRecipe) {
    return <NoticeBox>No template selected</NoticeBox>;
  }

  return (
    <Table>
      <Table.Row className="candystripe">
        <Table.Cell>{stagedRecipe.name}</Table.Cell>
        <Table.Cell collapsing>
          <Button
            disabled={!stagedRecipe}
            onClick={() =>
              act('load', {
                path: stagedRecipe.path,
              })
            }
          >
            Load
          </Button>
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};

const findRecipeByName = (name, recipe_index) => {
  return (
    Object.values(recipe_index)
      .flatMap((category) => category.recipes)
      .find((recipe) => recipe.name === name) || null
  );
};

/**
 * Take entire recipes tree
 * and return a flat recipe list that matches search,
 * sorted by name and only the first page.
 * @param {any[]} recipes Recipes list.
 * @param {string} search The search term
 * @returns {any[]} The flat list of recipes.
 */
const searchForRecipes = (recipes, search) => {
  search = search.toLowerCase();

  return flow([
    (categories) => categories.flatMap((category) => category.recipes),
    filter(
      (recipe) =>
        recipe.name?.toLowerCase().includes(search.toLowerCase()) ||
        recipe.desc?.toLowerCase().includes(search.toLowerCase()),
    ),
    sortBy((recipe) => recipe.name),
    (recipes) => recipes.slice(0, 25),
  ])(recipes);
};

export const RecipeCatalog = (props) => {
  const { express } = props;
  const { act, data } = useBackend();

  const recipe_index = Object.values(data.recipe_index);

  const [activeCategoryName, setActiveCategoryName] = useSharedState(
    'category',
    recipe_index[0]?.name,
  );

  const [searchText, setSearchText] = useSharedState('search_text', '');

  const activeCategory =
    activeCategoryName === 'search_results'
      ? { recipes: searchForRecipes(recipe_index, searchText) }
      : recipe_index.find((category) => category.name === activeCategoryName);

  const [stagedRecipeName, setStagedRecipeName] = useSharedState(
    'staged_recipe_name',
    null,
  );

  return (
    <Section fill title="Recipes">
      <Flex>
        <Flex.Item ml={-1} mr={1}>
          <Tabs vertical>
            <Tabs.Tab
              key="search_results"
              selected={activeCategoryName === 'search_results'}
            >
              <Stack align="baseline">
                <Stack.Item>
                  <Icon name="search" />
                </Stack.Item>
                <Stack.Item grow>
                  <Input
                    fluid
                    placeholder="Search..."
                    value={searchText}
                    onInput={(e, value) => {
                      if (value === searchText) {
                        return;
                      }

                      if (value.length) {
                        // Start showing results
                        setActiveCategoryName('search_results');
                      } else if (activeCategoryName === 'search_results') {
                        // return to normal category
                        setActiveCategoryName(recipe_index[0]?.name);
                      }
                      setSearchText(value);
                    }}
                    onChange={(e, value) => {
                      // Allow edge cases like the X button to work
                      const onInput = e.target?.props?.onInput;
                      if (onInput) {
                        onInput(e, value);
                      }
                    }}
                  />
                </Stack.Item>
              </Stack>
            </Tabs.Tab>
            {recipe_index.map((category) => (
              <Tabs.Tab
                key={category.name}
                selected={category.name === activeCategoryName}
                onClick={() => {
                  setActiveCategoryName(category.name);
                  setSearchText('');
                }}
              >
                {category.name} ({category.recipes.length})
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          <Table>
            {activeCategory?.recipes.map((recipe) => {
              return (
                <Table.Row key={recipe.name} className="candystripe">
                  <Table.Cell>{recipe.name}</Table.Cell>
                  <Table.Cell collapsing textAlign="right">
                    <Button
                      tooltip={recipe.desc}
                      tooltipPosition="left"
                      onClick={() => {
                        setStagedRecipeName(recipe.name);
                      }}
                    >
                      Select
                    </Button>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
