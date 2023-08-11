export const runs = [
  {
    author: 'Luke Skywalker',
    bookmark: true,
    id: '2021-09-08T10:55:36.810Z',
    gitSha: 'ad60192',
    gitBranch: 'feature/new-feature',
    runCommand: 'kedro run --pipeline my_pipeline',
    notes:
      'But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful.',
    title: 'My Favorite Sprint',
  },
  {
    author: 'Leia Organa',
    bookmark: false,
    id: '2021-09-07T11:36:24.560Z',
    gitSha: 'bt60142',
    gitBranch: 'feature/new-feature',
    runCommand: 'kedro run --pipeline my_pipeline',
    notes:
      'On the other hand, we denounce with righteous indignation and dislike men who are so beguiled.',
    title: 'Another favorite sprint',
  },
  {
    author: 'Obi-wan Kenobi',
    bookmark: false,
    id: '2021-09-04T04:36:24.560Z',
    gitSha: 'tz24689',
    gitBranch: 'feature/new-feature',
    runCommand: 'kedro run --pipeline my_pipeline',
    notes:
      'On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment',
    title: 'Slick test this one',
  },
];

export const trackingData = {
  json: [
    {
      datasetName: 'Data Analysis',
      data: {
        classWeight: [
          { runId: 'My Favorite Sprint', value: 23 },
          { runId: 'Another favorite sprint', value: 21 },
          { runId: 'Slick test this one', value: 21 },
        ],
        bootstrap: [
          { runId: 'My Favorite Sprint', value: 0.8 },
          { runId: 'Another favorite sprint', value: 0.5 },
          { runId: 'Slick test this one', value: 1 },
        ],
      },
      runIds: [
        'My Favorite Sprint',
        'Another favorite sprint',
        'Slick test this one',
      ],
    },
    {
      datasetName: 'Shopper Spend Raw',
      data: {
        maxFeatures: [
          { runId: 'My Favorite Sprint', value: 'auto' },
          { runId: 'Another favorite sprint', value: 'min' },
          { runId: 'Slick test this one', value: 'max' },
        ],
        minSamplesLeaf: [
          { runId: 'My Favorite Sprint', value: 12564 },
          { runId: 'Another favorite sprint', value: 34524 },
          { runId: 'Slick test this one', value: 23987 },
        ],
      },
      runIds: [
        'My Favorite Sprint',
        'Another favorite sprint',
        'Slick test this one',
      ],
    },
    {
      datasetName: 'Classical Analysis',
      data: {
        AU_SSID_NULLS: [
          { runId: 'My Favorite Sprint', value: 54.3 },
          { runId: 'Another favorite sprint', value: 55.1 },
          { runId: 'Slick test this one', value: 54.7 },
        ],
        AR_ARM_NULLS: [
          { runId: 'My Favorite Sprint', value: 123 },
          { runId: 'Another favorite sprint', value: 345 },
          { runId: 'Slick test this one', value: 456 },
        ],
      },
      runIds: [
        'My Favorite Sprint',
        'Another favorite sprint',
        'Slick test this one',
      ],
    },
  ],
};
