const data = [
  [
    173,
    0,
    '#1Философский психотип:#0 Эти пациенты обычно подходят к своему лечению с пониманием и реалистичными ожиданиями. Они спокойно принимают как положительные, так и отрицательные стороны процедур и способны адекватно адаптироваться к необходимости лечения. Они способны смотреть на вещи с разных сторон и не склонны к эмоциональным перепадам. Такие пациенты часто проявляют терпение и открыты к дискуссиям о различных вариантах лечения, взвешивая все "за" и "против".',
    ''
  ],
  [
    174,
    173,
    'Пациент рационально воспринимает информацию о лечении',
    '#1Рациональное отношение к лечению:#0 Пациент подходит к своему лечению с пониманием и рациональностью. Он склонен анализировать информацию и задавать вдумчивые вопросы и искать компромиссы.'
  ],
  [
    175,
    173,
    'Пациент с терпением и спокойствием относится к неувязкам',
    '#1Терпеливость и спокойствие:#0 Пациент сохраняет спокойствие и терпение даже в случае неожиданных новостей или задержек в лечении.'
  ],
  [
    176,
    173,
    'Пациент в точности следует рекомендациям',
    '#1Готовность к сотрудничеству:#0 Пациент проявляет готовность сотрудничать с врачом и следовать медицинским рекомендациям.'
  ],
  [
    177,
    173,
    'Пациент руководствуется здравым смыслом при выборе лечения',
    '#1Обдуманные решения:#0 Пациент принимает взвешенные, обдуманные решения относительно своего лечения, не поддаваясь импульсивности или эмоциям.'
  ],
  [
    178,
    173,
    'Пациент реалистично представляет результаты лечения',
    '#1Реалистичные ожидания:#0 Пациент имеет реалистичные ожидания относительно исхода лечения и готов принимать как положительные, так и отрицательные аспекты медицинских процедур.'
  ],
  [
    179,
    173,
    'Пациент настроен на работу по устранению возникших осложнений',
    '#1Спокойное приятие проблем и неудач:#0 В случае возникновения проблем или неудач в процессе лечения, пациент склонен рассматривать их как возможность для обучения или развития, а не как катастрофу.'
  ],
  [
    180,
    173,
    'Пациент старается получить больше знаний для понимания лечения',
    '#1Глубокое понимание ситуации:#0 Пациент стремится понять более глубокие аспекты своего заболевания и лечения, а не только поверхностные детали.'
  ],
  [
    181,
    0,
    '#1Требовательный психотип:#0 Этот тип пациентов характеризуется высокими ожиданиями и критичностью. Они могут быть весьма требовательными к деталям и качеству обслуживания. Требовательные пациенты часто стремятся контролировать каждый аспект лечения и могут быть недовольны, если результаты не соответствуют их ожиданиям.',
    ''
  ],
  [
    182,
    181,
    'Пациент имеет завышенные ожидания',
    '#1Высокие ожидания:#0 Пациенты имеет очень высокие или даже нереалистичные ожидания относительно результатов лечения и качества обслуживания.'
  ],
  [
    183,
    181,
    'Пациент делает критические замечания',
    '#1Критичность:#0 Пациент критикует и часто высказывают недовольство различными аспектами лечения, условиями в клинике или взаимодействием с персоналом.'
  ],
  [
    184,
    181,
    'Пациент плохо переносит ошибки',
    '#1Нетерпимость к ошибкам:#0 Пациент плохо переносит любые ошибки или недочеты, даже малозначительные, и может реагировать на них чрезмерно эмоционально.'
  ],
  [
    185,
    181,
    'Пациент задает излишние вопросы',
    '#1Частые запросы и вопросы:#0 Пациент задает множество вопросов и делает частые запросы, требуя дополнительного внимания и времени.'
  ],
  [
    186,
    181,
    'Пациент не сотрудничает с персоналом',
    '#1Непростое взаимодействие с персоналом:#0 Общение с пациентом достаточно сложное. Он настойчив, иногда агрессивен или недоволен предложенными решениями.'
  ],
  [
    187,
    181,
    'Пациент требует индивидуального подхода',
    '#1Требования персонализированного подхода:#0 Пациент требует индивидуального подхода и не хочет принимать стандартные процедуры или рекомендации.'
  ],
  [
    188,
    181,
    'Пациент настаисает на своем мнении',
    '#1Настойчивость:#0 Пациент настаивает на своем мнении, даже если оно противоречит медицинским рекомендациям.'
  ],
  [
    189,
    0,
    '#1Безразличный психотип:#0 Пациенты этого типа часто кажутся равнодушными к своему лечению. Они могут не проявлять интерес к информации, которую предоставляет врач, и не активно участвовать в процессе лечения. Их может быть сложно мотивировать на следование медицинским рекомендациям и регулярные посещения клиники.',
    ''
  ],
  [
    190,
    189,
    'Пациент не интересуется лечением',
    '#1Отсутствие интереса:#0 Пациент проявляет мало интереса к своему лечению. Он кажется равнодушными к информации, которую предоставляет стоматолог, и не задает вопросов.'
  ],
  [
    191,
    189,
    'Пациент не заинтересован в общении',
    '#1Минимальное взаимодействие:#0 Пациент ограничивается короткими и сдержанными ответами на вопросы врача, избегает разговоров и кажется не заинтересованным в общении.'
  ],
  [
    192,
    189,
    'Пациент пропускает запланированные визиты',
    '#1Нерегулярное посещение врача:#0 Пациент часто пропускает запланированные визиты или не придерживается рекомендованного плана лечения.'
  ],
  [
    193,
    189,
    'Пациент игнорирует рекомендации',
    '#1Игнорирование медицинских советов:#0 Пациент игнорирует советы по уходу за полостью рта и другие рекомендации, предложенные стоматологом.'
  ],
  [
    194,
    189,
    'Пациент не проявляет озабоченности своим здоровьем',
    '#1Отсутствие реакции на проблемы:#0 Даже при наличии зубной боли или других проблем со здоровьем полости рта, пациент не проявляет особой озабоченности.'
  ],
  [
    195,
    189,
    'Пациент не мотивирован к востановлению здоровья',
    '#1Недостаток мотивации:#0 У пациента отсутствует мотивация к улучшению своего дентального здоровья или косметическому восстановлению зубов.'
  ],
  [
    196,
    189,
    'Пациент не самостоятелен в решениях',
    '#1Наличие лица принимающего решения:#0 У пациента есть человек к чьему мнению он прислушивается и который принимает за него важные решения. Обычно мать или супруг.'
  ],
  [
    197,
    0,
    '#1Театральный (или эмоциональный) психотип:#0 Этот тип пациентов склонен к драматизации и чрезмерным эмоциональным реакциям. Они могут проявлять преувеличенную чувствительность к боли или дискомфорту, их поведение может быть непредсказуемым и изменчивым. Такие пациенты часто нуждаются в дополнительном внимании и поддержке во время лечения.',
    ''
  ],
  [
    198,
    197,
    'Пациент черезмерно эмоционален',
    '#1Эмоциональная экспрессивность:#0 Пациент часто выражает свои эмоции очень ярко и драматично. Он может быстро менять свое настроение или реагировать чрезмерно эмоционально на обычные ситуации.'
  ],
  [
    199,
    197,
    'Пациент черезмерно озабочен своим здоровьем',
    '#1Избыточная тревожность по поводу своего здоровья:#0 Пациент проявляет чрезмерную озабоченность своим физическим состоянием или стоматологическими процедурами, даже если нет серьезных оснований для беспокойства.'
  ],
  [
    200,
    197,
    'Пациент пытается привлечь внимание',
    '#1Стремление к вниманию:#0 Пациент стремиться быть в центре внимания, подчеркивая свои проблемы и переживания.'
  ],
  [
    201,
    197,
    'Пациент нестабилен в отношении персонала',
    '#1Нестабильность в восприятии и отношениях:#0 Отношение пациента к стоматологу и медицинскому персоналу может быстро меняться от идеализации до недовольства.'
  ],
  [
    202,
    197,
    'Пациент преувеличивает свои проблемы',
    '#1Преувеличение симптомов:#0 Пациент преувеличивает симптомы или боли, иногда делая это для привлечения внимания или из-за повышенной чувствительности.'
  ],
  [
    203,
    197,
    'Пациент не осознает ответственности за свое здоровье',
    '#1Избегание ответственности:#0 Пациенты могут избегать ответственности за свое здоровье, ожидая от врача мгновенного и полного решения всех их проблем.'
  ],
  [
    204,
    197,
    'Пациент остро реагируетна критику и отказ',
    '#1Чувствительность к отклонению или критике:#0 Пациенты могут реагировать чрезмерно болезненно на критику или отказ в их просьбах.'
  ],
];
